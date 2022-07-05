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
public class KeyStorage : Object {

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
    secret_schema = new Secret.Schema ("uk.co.ibboard.Cawbird",
                                       Secret.SchemaFlags.NONE,
                                       "type",       Secret.SchemaAttributeType.STRING,
                                       "identifier", Secret.SchemaAttributeType.STRING,
                                       "secret",     Secret.SchemaAttributeType.BOOLEAN
                                      );
  }

#if SUPPORT_MASTODON
  /**
   * Store the access tokens for a Server.
   *
   * @param server The Server which tokens are to be stored.
   * @param identifier The identifier used to store the token.
   *
   * @throws Error Any error that happens while storing the token.
   */
  public static async void store_server_access (Backend.Server server, string identifier) throws Error {
    // Fail on attempting to non Mastodon servers
    if (! (server is Backend.Mastodon.Server)) {
      error ("Only Mastodon servers should be stored!");
    }

    // Create the attributes
    string token_label;
    var    attributes        = new GLib.HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Server";
    attributes["identifier"] = identifier;

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
   * @param identifier The identifier used to store the tokens.
   * @param token A reference which will hold the retrieved token.
   * @param secret A reference which will hold the retrieved secret.
   *
   * @throws Error Any error that happens while retrieving the token.
   */
  public static async void retrieve_server_access (    string   identifier,
                                                   out string   token,
                                                   out string   secret)
                                                         throws Error {
    // Create the attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Server";
    attributes["identifier"] = identifier;

    try {
      // Load the client token
      attributes["secret"] = "false";
      token = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);

      // Load the client secret
      attributes["secret"] = "true";
      secret = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Removes the access tokens for a Server.
   *
   * @param identifier The identifier used to store the tokens.
   *
   * @throws Error Any error that happens while removing the token.
   */
  public static async void remove_server_access (string identifier) throws Error {
    // Create the attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Server";
    attributes["identifier"] = identifier;

    try {
      // Clear the client token
      attributes["secret"] = "false";
      Secret.password_clearv_sync (instance.secret_schema, attributes, null);

      // Clear the client secret
      attributes["secret"] = "true";
      Secret.password_clearv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }
  }
#endif

  /**
   * Store the access tokens for a Account.
   *
   * @param account The Account which tokens are to be stored.
   * @param identifier The identifier used to store the token.
   *
   * @throws Error Any error that happens while storing the token.
   */
  public static async void store_account_access (Backend.Account account, string identifier) throws Error {
    // Create the attributes
    string platform_name     = PlatformEnum.get_platform_for_account (account).to_string ();
    var    attributes        = new HashTable<string,string> (str_hash, str_equal);
    string token_label       = @"Access Token for Account \"$(account.username)\" on $(platform_name)";
    attributes["type"]       = "Account";
    attributes["identifier"] = identifier;
    attributes["secret"]     = "false";

    // Store the access token
    try {
      Secret.password_storev_sync (instance.secret_schema, attributes,
                                   Secret.COLLECTION_DEFAULT, token_label,
                                   account.access_token, null);
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
   * @param identifier The identifier used to store the token.
   * @param token A reference which will hold the retrieved token.
   *
   * @throws Error Any error that happens while retrieving the token.
   */
  public static async void retrieve_account_access (    string identifier,
                                                    out string token)
                                                        throws Error {
    // Create the attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Account";
    attributes["identifier"] = identifier;
    attributes["secret"]     = "false";

    // Load the client token
    try {
      token = Secret.password_lookupv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Removes the access tokens for a Account.
   *
   * @param identifier The identifier used to store the token.
   *
   * @throws Error Any error that happens while removing the token.
   */
  public static async void remove_account_access (string identifier) throws Error {
    // Create the attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["type"]       = "Account";
    attributes["identifier"] = identifier;
    attributes["secret"]     = "false";

    // Clear the access token
    try {
      Secret.password_clearv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
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
