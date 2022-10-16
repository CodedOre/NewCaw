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
   * Creates a new instance of Session.
   *
   * @param account The account for this session.
   *
   * @return A session suitable for the set account.
   */
  public static Session for_account (Account account) {
    switch (PlatformEnum.for_account (account)) {
      case MASTODON:
        return new Mastodon.Session (account);
      case TWITTER:
        return new Twitter.Session (account);
      default:
        error ("No compatible session type found for this account!");
    }
  }

  /**
   * The account that is managed by this session.
   */
  public Account account { get; construct; }

  /**
   * Run at construction of this session.
   */
  construct {
    // Initialize the content storage.
    pulled_posts = new HashTable <string, Post> (str_hash, str_equal);
    pulled_users = new HashTable <string, User> (str_hash, str_equal);
  }

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
  internal abstract async Post pull_post (string id) throws Error;

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
  internal abstract async User pull_user (string id) throws Error;

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
   * Stores a reference to each post pulled by this session.
   */
  protected HashTable <string, Post> pulled_posts;

  /**
   * Stores a reference to each user pulled by this session.
   */
  protected HashTable <string, User> pulled_users;

}
