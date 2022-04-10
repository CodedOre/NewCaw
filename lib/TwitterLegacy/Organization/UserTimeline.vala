/* UserTimeline.vala
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
 * The timeline of Posts a certain User has created.
 */
public class Backend.TwitterLegacy.UserTimeline : Backend.UserTimeline {

  /**
   * Creates a UserTimeline for a User.
   *
   * @param user The User for which the timeline is to be created.
   * @param account The Account used for making the API calls.
   */
  public UserTimeline (Backend.User user, Backend.Account account) {
    // Construct the object
    Object (
      post_list: new ListStore (typeof (Backend.Post)),
      user: user
    );

    // Set the call_account
    call_account = account;
  }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public override async void pull_posts () throws Error {
  }

}
