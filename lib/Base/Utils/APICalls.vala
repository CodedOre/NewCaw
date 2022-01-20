/* APICalls.vala
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
 * Domain for errors that happened during an API call.
 */
errordomain Backend.APICallError {
  /**
   * An (to this backend) unknown error.
   */
  UNDEFINED
}

/**
 * Methods for calling the API.
 */
namespace Backend.APICalls {

  /**
   * Runs the given Rest.ProxyCall and returns the result in a Json.Object.
   *
   * @param call The call to be run, create it with Account.create_call.
   *
   * @return A Json.Object with the response of the call.
   *
   * @throws Error Errors that happened either while loading or parsing.
   */
  private async Json.Object get_data (Rest.ProxyCall call) throws Error {
    // Run the call
    try {
      yield call.invoke_async (null);
    } catch (Error e) {
      throw e;
    }

    // TODO: Check the response header

    // Get the result and converts it to a json object
    string result = call.get_payload ();
    var    parser = new Json.Parser ();

    try {
      parser.load_from_data (result);
    } catch (Error e) {
      throw e;
    }

    Json.Node root = parser.get_root ();
    return root.get_object ();
  }

}
