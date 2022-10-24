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
 * Stores access tokens securely using the libsecret library.
 */
[SingleInstance]
internal class Backend.KeyStorage : Object {

  /**
   * The global instance of KeyStorage.
   */
  private static KeyStorage instance {
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
                                       "identifier", Secret.SchemaAttributeType.STRING
                                      );
  }

  /**
   * Retrieves an access from the storage.
   *
   * @param identifier The id for the secret to be accessed.
   *
   * @return The access token from the storage.
   *
   * @throws Error Errors while accessing the secret storage.
   */
  public static string retrieve_access (string identifier) throws Error {
    // Create the call attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["identifier"] = identifier;

    // Load the client token
    try {
      return Secret.password_lookupv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Stores an access to the storage.
   *
   * @param secret The secret to be stored in the storage.
   * @param identifier The id for the secret to be stored.
   * @param label A descriptive label set for the token.
   *
   * @throws Error Errors while accessing the secret storage.
   */
  public static void store_access (string secret, string identifier, string label) throws Error {
    // Create the call attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["identifier"] = identifier;

    // Load the client token
    try {
      Secret.password_storev_sync (instance.secret_schema, attributes,
                                   Secret.COLLECTION_DEFAULT, label,
                                   secret, null);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Removes the access from the storage.
   *
   * @param identifier The id for the secret to be removed.
   *
   * @throws Error Errors while accessing the secret storage.
   */
  public static void remove_access (string identifier) throws Error {
    // Create the attributes
    var attributes           = new HashTable<string,string> (str_hash, str_equal);
    attributes["identifier"] = identifier;

    // Clear the access token
    try {
      Secret.password_clearv_sync (instance.secret_schema, attributes, null);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Stores the global instance of KeyStorage.
   */
  private static KeyStorage? global_instance = null;

  /**
   * The password scheme used to identify passwords for this backend.
   */
  private Secret.Schema secret_schema;

}
