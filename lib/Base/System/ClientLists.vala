/* ClientLists.vala
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
 * Provides a list of all sessions used by a Client.
 */
public class Backend.SessionList : Backend.Collection<Session> {

  /**
   * Creates a new instance of SessionList.
   */
  internal SessionList () {
    Object ();
  }

  /**
   * Add a new session to the session list.
   *
   * @param session The session to be added.
   *
   * @throws Error Errors when saving the secrets to the KeyStorage.
   */
  internal void add (Session session) throws Error {
    // Avoid duplicates
    if (find (session, null)) {
      return;
    }

    // Save session secrets
    try {
      PlatformEnum platform = PlatformEnum.for_session (session);
      string name_label   = session.account.username;
      string domain_label = session.server.domain;
      string token_label  = @"Access Token for Account \"$(name_label)@$(domain_label)\" on $(platform)";
      KeyStorage.store_access (session.access_token, session.identifier, token_label);
    } catch (Error e) {
      throw e;
    }

    // Add the session to the list
    add_item (session);
  }

  /**
   * Removes a session from the session list.
   *
   * @param session The session to be removed.
   *
   * @throws Error Errors when removing the secrets to the KeyStorage.
   */
  internal void remove (Session session) throws Error {
    // Ignore if session don't exists in list
    if (! find (session, null)) {
      return;
    }

    // Remove session secrets
    try {
      KeyStorage.remove_access (session.identifier);
    } catch (Error e) {
      throw e;
    }

    // Remove the session from the list
    remove_item (session);
  }

  /**
   * Used to compares two iterators in the list when sorting.
   *
   * @param a The first iterator to compare.
   * @param b The second iterator to compare.
   *
   * @return How the iterators are sorted (positive when a before b, negative when b before a).
   */
  protected override int sort_func (SequenceIter<Session> a, SequenceIter<Session> b) {
    Session session_a = a.get ();
    Session session_b = b.get ();
    Server  server_a  = session_a.server;
    Server  server_b  = session_b.server;

    // Group sessions according to servers first
    if (server_a != server_b) {
      return strcmp (server_a.domain, server_b.domain);
    }

    // Then sort after account name
    return strcmp (session_a.account.username, session_b.account.username);
  }

}

/**
 * Provides a list of all servers used by a Client.
 */
public class Backend.ServerList : Backend.Collection<Server> {

  /**
   * Creates a new instance of ServerList.
   */
  internal ServerList () {
    Object ();
  }

  /**
   * Add a new server to the server list.
   *
   * @param server The server to be added.
   *
   * @throws Error Errors when saving the secrets to the KeyStorage.
   */
  internal void add (Server server) throws Error {
    // Avoid duplicates
    if (find (server, null)) {
      return;
    }

    // Save server secrets
    try {
      PlatformEnum platform = PlatformEnum.for_server (server);
      string token_label = @"Access Token for Server \"$(server.domain)\" on $(platform)";
      KeyStorage.store_access (server.client_key, @"ck_$(server.identifier)", token_label);
      string secret_label = @"Access Secret for Server \"$(server.domain)\" on $(platform)";
      KeyStorage.store_access (server.client_secret, @"cs_$(server.identifier)", secret_label);
    } catch (Error e) {
      throw e;
    }

    // Add the server to the list
    add_item (server);
  }

  /**
   * Removes a server from the server list.
   *
   * @param server The server to be removed.
   *
   * @throws Error Errors when removing the secrets to the KeyStorage.
   */
  internal void remove (Server server) throws Error {
    // Ignore if server don't exists in list
    if (! find (server, null)) {
      return;
    }

    // Remove server secrets
    try {
      KeyStorage.remove_access (@"ck_$(server.identifier)");
      KeyStorage.remove_access (@"cs_$(server.identifier)");
    } catch (Error e) {
      throw e;
    }

    // Remove the server from the list
    remove_item (server);
  }

  /**
   * Used to compares two iterators in the list when sorting.
   *
   * @param a The first iterator to compare.
   * @param b The second iterator to compare.
   *
   * @return How the iterators are sorted (positive when a before b, negative when b before a).
   */
  protected override int sort_func (SequenceIter<Server> a, SequenceIter<Server> b) {
    Server server_a = a.get ();
    Server server_b = b.get ();
    return strcmp (server_a.domain, server_b.domain);
  }

}
