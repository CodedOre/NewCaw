/* Client.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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
 * The client for utilizing this backend.
 *
 * This class provides information about the client to other methods of the
 * backend and provides methods to initialize and shutdown the backend during
 * an application run.
 *
 * Before using anything else from the backend, Client must be initialized.
 */
[SingleInstance]
public partial class Backend.Client : Initable {

  public signal void auth_callback (string state, string code);

  /**
   * The global instance of the client.
   */
  public static Client? instance {
    get {
      if (global_instance == null) {
        critical ("Client must be initialized first!");
      }
      return global_instance;
    }
  }

  /**
   * The id of the client.
   *
   * Is expected to be a reverse domain and to be the
   * same as the application id utilizing the backend.
   */
  public string id { get; internal set; }

  /**
   * The name of the client.
   */
  public string name { get; internal set; }

  /**
   * A website for more information on a client.
   *
   * Used by backends that create OAuth applications on the
   * fly (e.g. Mastodon) to provide a link for the user while
   * authorizing a new session.
   */
  public string website { get; internal set;  }

  /**
   * An optional redirect uri used during authentication.
   *
   * Can be provided to the authenticating server to automatically redirect
   * the user from the webpage back to the client after he has authorized
   * it on the OAuth page.
   *
   * If set to null, the out-of-band uri for a specific platform is used instead.
   */
  public string? redirect_uri { get; internal set;  }

  /**
   * All sessions that are active with this client.
   */
  public SessionList sessions { get; construct; }

  /**
   * All servers that are active with this client.
   */
  public ServerList servers { get; construct; }

  /**
   * Configures the client instance.
   *
   * @param id The identifier for the client.
   * @param name The name of the client.
   * @param website The website for the client.
   * @param redirect_uri An optional redirect uri.
   */
  public Client (string id, string name, string website, string? redirect_uri = null, string state_path) {
    Object (
      id: id,
      name: name,
      website: website,
      redirect_uri: redirect_uri,
      sessions: new SessionList (),
      servers: new ServerList ()
    );
    this.state_path = state_path;
    try {
      init ();
    } catch (Error e) {
      critical (@"Failed to initialize client: $(e.message)");
    }

    // Set the global instance
    global_instance = this;
  }

  /**
   * Initializes the object after constructions.
   *
   * For more information view the docs for Initable.
   *
   * @param cancellable Allows the initialization of the class to be cancelled.
   *
   * @return If the object was successfully initialized.
   *
   * @throws Error Errors that happened while loading the account.
   */
  public bool init (Cancellable? cancellable = null) throws Error {
    // Initialize the class variables
    return true;
  }

  /**
   * Cleans up backend-related stuff when the client is exited.
   */
  public void shutdown () {
    MediaLoader.instance.shutdown ();
  }

  /**
   * Stores the global instance of Client.
   */
  private static Client? global_instance = null;

  /**
   * The path to the directory holding the state storage.
   */
  private string state_path;

}
