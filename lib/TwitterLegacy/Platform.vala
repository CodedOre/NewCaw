/* Platform.vala
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
 * The backend for the Twitter 1.0 API.
 */
namespace Backend.TwitterLegacy {

  /**
   * Base information about the platform used by the backend.
   */
  public class Platform : Object {

    /**
     * The fixed domain for this platform.
     */
    internal const string DOMAIN = "Twitter.com";

    /**
     * The key to authenticate the client to the platform.
     */
    public static string client_key {
      get {
        return instance.stored_client_key;
      }
    }

    /**
     * The secret to authenticate the client to the platform.
     */
    public static string client_secret {
      get {
        return instance.stored_client_secret;
      }
    }

    /**
     * The global instance for the platform.
     */
    private static Platform instance {
      get {
        if (stored_instance != null) {
          critical ("TwitterLegacy platform was not initialized!");
        }
        return stored_instance;
      }
    }

    /**
     * Initializes the platform for use.
     *
     * @param key The oauth key for the app.
     * @param secret The oauth secret for the app.
     */
    public static void init (string key, string secret) {
      // Check if no instance was already initialized
      if (stored_instance != null) {
        error ("TwitterLegacy platform already initialized!");
      }

      // Create the instance for the singleton
      stored_instance = new Platform ();

      // Set the key and secret
      stored_instance.stored_client_key    = key;
      stored_instance.stored_client_secret = secret;
    }

    /**
     * Stores the client_key inside the instance.
     */
    private string stored_client_key;

    /**
     * Stores the client_secret inside the instance.
     */
    private string stored_client_secret;

    /**
     * Stores the global instance for the platform.
     */
    private static Platform? stored_instance = null;

  }

}
