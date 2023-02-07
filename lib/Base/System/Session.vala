/* Session.vala
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
 * Holds an active session in a client.
 *
 * This class provides the utilities to manage a session with one account which
 * is displayed in the account, and provides the possibility to store data of
 * the window displaying the session when the backend is shutdown.
 *
 * It also contains the methods for an application to retrieve content, as it
 * keeps an reference to posts, users, etc. loaded from a specific account.
 */
public abstract class Backend.Session : Object {

  /**
   * Creates an Session object from set data.
   *
   * Used to restore a session from an saved state.
   *
   * @param identifier The identifier for the session.
   * @param access_token The access token to make calls for this session.
   * @param server The server which this server calls.
   *
   * @return A newly created Session instance from the set data.
   *
   * @throws Error Errors that happen while verifying the session by loading the account.
   */
  internal async static Session from_data (string identifier, string access_token, Server server) throws Error {
    switch (PlatformEnum.for_server (server)) {
#if SUPPORT_MASTODON
      case MASTODON:
        try {
          var session = new Mastodon.Session (identifier, access_token, server);
          yield session.init_async ();
          return session;
        } catch (Error e) {
          throw e;
        }
#endif

      default:
        error ("Can't create session for unknown server platform!");
    }
  }

  /**
   * The access token to make calls for this session.
   */
  public string access_token { get; protected construct set; }

  /**
   * The server this session is connected to.
   */
  public weak Server server { get; construct; }

  /**
   * The account that is managed by this session.
   */
  public User account { get; protected set; }

  /**
   * Used to identify this object when storing and restoring a ClientState.
   *
   * This should be set once on authentication, but not modified afterwards.
   */
  internal string identifier { get; protected set; }

  /**
   * Retrieves an post for an specified id.
   *
   * If the post was already pulled and is present in memory, the version
   * from memory is used, otherwise a call to the servers will be made.
   *
   * @param id The id for the post.
   *
   * @return The post for the given id.
   *
   * @throws Error Any error that could happen while the post is pulled.
   */
  public abstract async Post pull_post (string id) throws Error;

  /**
   * Loads an post from downloaded data.
   *
   * If the post was already pulled and is present in memory, the version
   * from memory is used, otherwise a new object for the post is created.
   *
   * @param data The data for the post.
   *
   * @return The post created from the data.
   */
  internal abstract Post load_post (Json.Object data);

  /**
   * Loads a list of downloaded posts.
   *
   * If a post was already pulled and is present in memory, the version
   * from memory is used, otherwise a new object for the post is created.
   *
   * @param data The data for the post list.
   *
   * @return The post list created from the data.
   */
  internal abstract Post[] load_post_list (Json.Node json);

  /**
   * Retrieves an user for an specified id.
   *
   * If the user was already pulled and is present in memory, the version
   * from memory is used, otherwise a call to the servers will be made.
   *
   * @param id The id for the user.
   *
   * @return The user for the given username.
   *
   * @throws Error Any error that could happen while the user is pulled.
   */
  public abstract async User pull_user (string id) throws Error;

  /**
   * Loads an user from downloaded data.
   *
   * If the user was already pulled and is present in memory, the version
   * from memory is used, otherwise a new object for the user is created.
   *
   * @param data The data for the user.
   *
   * @return The user created from the data.
   */
  internal abstract User load_user (Json.Object data);

  /**
   * Retrieves the HomeTimeline for the account in this session.
   *
   * In order to allow a ListView to include widgets before the posts,
   * the headers parameter can be added. For each string in that list
   * an PseudoItem will be created with the string as description.
   *
   * @param headers Descriptions for header items to be added.
   *
   * @return The HomeTimeline for the account of the session.
   */
  public abstract HomeTimeline get_home_timeline (string[] headers = {});

  /**
   * Retrieves the UserTime for a user in this session.
   *
   * In order to allow a ListView to include widgets before the posts,
   * the headers parameter can be added. For each string in that list
   * an PseudoItem will be created with the string as description.
   *
   * @param user The user to show the UserTimeline for.
   * @param headers Descriptions for header items to be added.
   *
   * @return The UserTimeline for the user of the session.
   */
  public abstract UserTimeline get_user_timeline (User user, string[] headers = {});

  /**
   * Retrieves the Thread for a post in this session.
   *
   * @param main_post The main post which serves as the focus for this thread.
   *
   * @return The Thread for the post of the session.
   */
  public abstract Thread get_thread (Post main_post);

  /**
   * Removes the session from the client.
   *
   * This will remove the authentication of the session from the
   * server and the saved data of the session in the client.
   *
   * @throws Error Any error occurring while removing the account.
   */
  public abstract async void revoke_session () throws Error;

  /**
   * Creates a Rest.ProxyCall to perform an API call.
   *
   * @return A Rest.ProxyCall that can be then called with Server.call.
   */
  internal abstract Rest.ProxyCall create_call ();

}
