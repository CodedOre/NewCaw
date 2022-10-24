/* Server.vala
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
 * Errors that happened while making an API Call.
 */
public errordomain Backend.CallError {

  /**
   * An (to this backend) unknown error.
   */
  UNDEFINED

}

/**
 * Stores the information to connect to a specific server.
 */
public abstract class Backend.Server : Object {

  /**
   * The domain of the server.
   *
   * This should only be the server domain, without protocol.
   */
  public string domain { get; construct; }

  /**
   * The key used to identify the client to the server.
   */
  public string client_key { get; protected set; }

  /**
   * The secret used to identify the client to the server.
   */
  public string client_secret { get; protected set; }

  /**
   * Used to identify this object when storing and restoring a ClientState.
   *
   * This should be set once on authentication, but not modified afterwards.
   */
  internal string identifier { get; protected set; }

  /**
   * Runs the given Rest.ProxyCall and returns the result as an Json.Node.
   *
   * @param call The call to be run, create it with Account.create_call.
   *
   * @return A Json.Node with the response of the call.
   *
   * @throws Error Errors that happened either while loading or parsing.
   */
  internal async Json.Node call (Rest.ProxyCall call, Cancellable? cancellable = null) throws Error {
    // Run the call
    try {
      yield call.invoke_async (cancellable);
    } catch (Error e) {
      throw e;
    }

    // Check for errors in the response
    try {
      check_call (call);
    } catch (CallError e) {
      throw e;
    }

    // Get the result and converts it to a json object
    string result = call.get_payload ();
    var    parser = new Json.Parser ();

    try {
      parser.load_from_data (result);
    } catch (Error e) {
      throw e;
    }

    return parser.get_root ();
  }

  /**
   * Checks an finished Rest.ProxyCall for occurred errors.
   *
   * Called by the call method, this is to be implemented by
   * sub-classes to read possible errors that happened
   * on a call and returns an CallError for it.
   *
   * @param call The call as run by call.
   *
   * @throws CallError Possible detected errors.
   */
  protected abstract void check_call (Rest.ProxyCall call) throws CallError;

}
