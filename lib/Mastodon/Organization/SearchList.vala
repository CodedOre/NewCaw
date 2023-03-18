/* SearchList.vala
 *
 * Copyright 2023 Frederick Schenk
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
 * Provides a list containing the results of an search.
 */
public class Backend.Mastodon.SearchList : Backend.SearchList {

  /**
   * Creates a SearchList for a search term.
   *
   * In order to allow a ListView to include widgets before the posts,
   * the headers parameter can be added. For each string in that list
   * an PseudoItem will be created with the string as description.
   *
   * @param session The Session that this timeline is assigned to.
   * @param search_term The string used to make the search.
   * @param headers Descriptions for header items to be added.
   */
  internal SearchList (Session session, string search_term, string[] headers = {}) {
    // Construct the object
    Object (
      session:     session,
      search_term: search_term,
      headers:     headers
    );
  }

  /**
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public override async void pull_items () throws Error {
  }

  /**
   * Calls the API to retrieve additional search results for posts.
   *
   * @throws Error Any error while accessing the API and pulling the posts.
   */
  public override async void pull_additional_posts () throws Error {
  }

  /**
   * Calls the API to retrieve additional search results for users.
   *
   * @throws Error Any error while accessing the API and pulling the users.
   */
  public override async void pull_additional_users () throws Error {
  }

}
