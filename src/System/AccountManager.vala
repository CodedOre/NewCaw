/* AccountManager.vala
 *
 * Copyright 2022 Frederick Schenk
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using GLib;

/**
 * Manages the Accounts used with this client.
 *
 * This class is responsible to load and to store
 * connected Accounts to the storage.
 */
[SingleInstance]
public class AccountManager : Object {

  /**
   * The single instance of this class.
   */
  public static AccountManager instance {
    get {
      if (global_instance == null) {
        global_instance = new AccountManager ();
      }
      return global_instance;
    }
  }

  /**
   * Constructs the instance.
   */
  private AccountManager () {
    // Initialize the arrays
    account_list = {};
    server_list  = {};
  }

  /**
   * Adds an Server to the list of managed servers.
   *
   * @param server The Server to be added.
   */
  public static void add_server (Backend.Server server) {
    instance.server_list += server;
  }

  /**
   * Adds an Account to the list of managed accounts.
   *
   * @param account The Account to be added.
   */
  public static void add_account (Backend.Account account) {
    instance.account_list += account;
  }

  /**
   * Returns all accounts managed by this class.
   *
   * @return An array of all accounts managed.
   */
  public static Backend.Account[] get_accounts () {
    return instance.account_list;
  }

  /**
   * Loads managed accounts and servers from the storage.
   *
   * @throws Error Errors that happen when loading fails.
   */
  public static async void load_data () throws Error {
    // Load settings
    var account_settings = new Settings ("uk.co.ibboard.Cawbird.Accounts");

    // Load the shortlists from the settings
    Variant mastodon_list       = account_settings.get_value ("mastodon-accounts");
    Variant twitter_list        = account_settings.get_value ("twitter-accounts");
    Variant twitter_legacy_list = account_settings.get_value ("twitter-legacy-accounts");

    // Parse through all Mastodon accounts
    VariantIter mastodon_iter = mastodon_list.iterator ();
    while (true) {
      // Get the data as Variant
      Variant? iter_variant = mastodon_iter.next_value ();
      if (iter_variant == null) {
        break;
      }

      // Get the server information
      string domain;
      iter_variant.get_child (0, "s", out domain);

      // Create server instance
      Backend.Mastodon.Server? server;
      try {
        // Get server access
        string server_token, server_secret;
        yield KeyStorage.retrieve_server_access (MASTODON, domain, out server_token, out server_secret);

        // Create server object
        server = new Backend.Mastodon.Server (domain, server_token, server_secret);
        assert (server != null);
        add_server (server);
      } catch (Error e) {
        throw e;
      }

      // Get the accounts array for this server
      VariantIter accounts = iter_variant.get_child_value (1).iterator ();
      string acc;
      while (accounts.next ("s", out acc)) {
        // Create account instance
        try {
          // Get account access
          string account_token;
          yield KeyStorage.retrieve_account_access (MASTODON, @"$(acc)@$(domain)", out account_token, null);

          // Create account object
          var account = new Backend.Mastodon.Account (server);
          assert (account != null);
          add_account (account);

          // Login the account async
          account.login.begin (account_token);
        } catch (Error e) {
        }
      }
    }
  }

  /**
   * Saves all managed accounts and servers to the storage.
   *
   * @throws Error Errors that happen when storage fails.
   */
  public static async void store_data () throws Error {
    // Store servers
    foreach (Backend.Server server in instance.server_list) {
      // Only store if Mastodon server
      if (server is Backend.Mastodon.Server) {
        // Store access tokens
        try {
          yield KeyStorage.store_server_access (server);
        } catch (Error e) {
          throw e;
        }
      }
    }

    // Create dictionary to build up the server categorization
    var mastodon_categorizer   = new HashTable<string,Array> (str_hash, str_equal);

    // Create VariantBuilders for shortlists
    var mastodon_builder       = new VariantBuilder (new VariantType ("a{sas}"));
    var twitter_builder        = new VariantBuilder (new VariantType ("as"));
    var twitter_legacy_builder = new VariantBuilder (new VariantType ("as"));

    // Store accounts
    foreach (Backend.Account account in instance.account_list) {
      // Store access tokens
      try {
        yield KeyStorage.store_account_access (account);
      } catch (Error e) {
        throw e;
      }

      // Store username in shortlist
      if (account is Backend.Mastodon.Account) {
        // Get the list of accounts set for a specific domain
        Array<string> server_accounts;
        if (mastodon_categorizer.contains (account.domain)) {
          server_accounts = mastodon_categorizer [account.domain];
        } else {
          server_accounts                       = new Array<string> ();
          mastodon_categorizer [account.domain] = server_accounts;
        }

        // Add the account to the list
        server_accounts.append_val (account.username);
        continue;
      }
      if (account is Backend.Twitter.Account) {
        twitter_builder.add ("s", account.username);
        continue;
      }
      if (account is Backend.TwitterLegacy.Account) {
        twitter_legacy_builder.add ("s", account.username);
        continue;
      }

      // Fail if no platform was detected
      error (@"Account $(account.username) belongs to no platform!");
    }

    // Build the Mastodon variant
    foreach (string server in mastodon_categorizer.get_keys ()) {
      mastodon_builder.open (new VariantType ("{sas}"));
      mastodon_builder.add ("s", server);
      mastodon_builder.open (new VariantType ("as"));
      Array<string> server_accounts = mastodon_categorizer[server];
      foreach (string acc in server_accounts) {
        mastodon_builder.add ("s", acc);
      }
      mastodon_builder.close ();
      mastodon_builder.close ();
    }

    // Create Variants from the builders
    Variant mastodon_shortlist       = mastodon_builder.end ();
    Variant twitter_shortlist        = twitter_builder.end ();
    Variant twitter_legacy_shortlist = twitter_legacy_builder.end ();

    // Save shortlists
    var account_settings = new Settings ("uk.co.ibboard.Cawbird.Accounts");
    account_settings.set_value ("mastodon-accounts", mastodon_shortlist);
    account_settings.set_value ("twitter-accounts", twitter_shortlist);
    account_settings.set_value ("twitter-legacy-accounts", twitter_legacy_shortlist);
  }

  /**
   * Stores the single instance of this class.
   */
  private static AccountManager? global_instance = null;

  /**
   * Stores all accounts managed by this class.
   */
  private Backend.Account[] account_list;

  /**
   * Stores all servers managed by this class.
   */
  private Backend.Server[] server_list;

}
