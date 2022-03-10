/* KeyStorage.vala
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
 * Allows to store access tokens from a Server or Account.
 *
 * This uses the Secrets portal to securely store
 * the tokens in the users password storage.
 */
[SingleInstance]
public class Backend.Utils.KeyStorage : Object {

  /**
   * The global instance of KeyStorage.
   */
  public static KeyStorage instance {
    get {
      if (global_instance == null) {
        global_instance = new KeyStorage ();
      }
      return global_instance;
    }
  }

  /**
   * Constructs the KeyStorage instance.
   */
  private KeyStorage () {
    // Create the secrets schemas
    secret_schema = new Secret.Schema (Client.instance.id,
                                       Secret.SchemaFlags.NONE,
                                       "type",       Secret.SchemaAttributeType.STRING,
                                       "identifier", Secret.SchemaAttributeType.STRING,
                                       "secret",     Secret.SchemaAttributeType.BOOLEAN
                                      );
  }

  /**
   * Store the access tokens for a Server.
   *
   * @param server The Server which tokens are to be stored.
   *
   * @throws Error Any error that happens while storing the token.
   */
  public static async void store_server_access (Server server) throws Error {
    // Create the attributes
    string token_label;
    var    attributes        = new GLib.HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Server";
    attributes["identifier"] = server.domain;

    // Store the access
    try {
      // Store the client token
      token_label          = @"Client Token for Server \"$(server.domain)\"";
      attributes["secret"] = "false";
      Secret.password_storev_sync (instance.secret_schema, attributes,
                                   Secret.COLLECTION_DEFAULT, token_label,
                                   server.client_key, null);

      // Store the client secret
      token_label          = @"Client Secret for Server \"$(server.domain)\"";
      attributes["secret"] = "true";
      Secret.password_storev_sync (instance.secret_schema, attributes,
                                   Secret.COLLECTION_DEFAULT, token_label,
                                   server.client_secret, null);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Retrieves the access tokens for a Server.
   *
   * @param server The domain to the Server.
   * @param token A reference which will hold the retrieved token.
   * @param secret A reference which will hold the retrieved secret.
   */
  public static async void retrieve_server_access (string server, out string token, out string secret) {
    // Create the attributes
    var attributes           = new GLib.HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Server";
    attributes["identifier"] = server;

    // Store the access
    try {
      // Store the client token
      attributes["secret"] = "false";
      token = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);

      // Store the client secret
      attributes["secret"] = "true";
      secret = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }

    // Check if tokens were retrieved
    if (token == null || secret == null) {
      error ("Could not retrieve access tokens for server \"$(server)\"");
    }
  }

  /**
   * Store the access tokens for a Account.
   *
   * @param account The Account which tokens are to be stored.
   *
   * @throws Error Any error that happens while storing the token.
   */
  public static async void store_account_access (Account account) throws Error {
    // Create the attributes
    string token_label;
    var    attributes        = new GLib.HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Account";
    attributes["identifier"] = account.username;

    // Store the access
    try {
      // Store the access token
      token_label          = @"Access Token for Account \"$(account.username)\"";
      attributes["secret"] = "false";
      Secret.password_storev_sync (instance.secret_schema, attributes,
                                   Secret.COLLECTION_DEFAULT, token_label,
                                   account.access_token, null);

      // If account is from TwitterLegacy
      if (account is TwitterLegacy.Account) {
        // Cast account to subclass
        var legacy_account = account as TwitterLegacy.Account;

        // Store the access secret
        token_label          = @"Access Secret for Account \"$(account.username)\"";
        attributes["secret"] = "true";
        Secret.password_storev_sync (instance.secret_schema, attributes,
                                     Secret.COLLECTION_DEFAULT, token_label,
                                     legacy_account.access_secret, null);
      }
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Store the access tokens for a Account.
   *
   * Should the tokens be called for an Account originally
   * authenticated with OAuth 2.0, the secret parameter
   * is not needed and can be omitted.
   *
   * @param account The username for the account.
   * @param token A reference which will hold the retrieved token.
   * @param secret A reference which will hold the retrieved secret.
   */
  public static async void retrieve_account_access (string account, out string token, out string? secret = null) {
    // Create the attributes
    var attributes           = new GLib.HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Account";
    attributes["identifier"] = account;

    // Store the access
    try {
      // Store the client token
      attributes["secret"] = "false";
      token = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);

      // Store the client secret
      attributes["secret"] = "true";
      secret = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }

    // Check if tokens were retrieved
    if (token == null) {
      error ("Could not retrieve access tokens for account \"$(account)\"");
    }
  }

  /**
   * Stores the global instance of KeyStorage.
   *
   * Only access over the instance property!
   */
  private static KeyStorage? global_instance = null;

  /**
   * The password scheme used to identify passwords for this backend.
   */
  private Secret.Schema secret_schema;

}
