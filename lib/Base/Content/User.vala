/* User.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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
 * Stores information about one user of a platform.
 */
public abstract class Backend.User : Object {

  /**
   * The identifier of the user in the API.
   */
  public string id { get; protected set; }

  /**
   * The "name" of the user.
   */
  public string display_name { get; protected set; }

  /**
   * The unique handle of this user.
   */
  public string username { get; protected set; }

  /**
   * When this Profile was created on the platform.
   */
  public DateTime creation_date { get; protected set; }

  /**
   * A formatted description set for the Profile.
   */
  public string description { get; protected set; }

  /**
   * The website where this user is located.
   *
   * Mostly important for the Mastodon backend, where a user
   * can come from multiple site thanks to the federation.
   */
  public string domain { get; protected set; }

  /**
   * The url to visit this user on the original website.
   */
  public string url { get; protected set; }

  /**
   * The avatar image from this user.
   */
  public Media avatar { get; protected set; }

  /**
   * The header image for the detail page of this user.
   */
  public Media header { get; protected set; }

  /**
   * A ListModel containing the data fields for this user.
   *
   * The objects of this list can be expected
   * to be of the type UserDataField.
   */
  public ListModel data_fields { get; construct; }

  /**
   * How many people are following this Profile.
   */
  public int followers_count { get; protected set; }

  /**
   * How many people this Profile follows.
   */
  public int following_count { get; protected set; }

  /**
   * How many posts this Profile wrote.
   */
  public int posts_count { get; protected set; }

  /**
   * Emitted when data in this user has changed.
   */
  public signal void user_updated ();

  /**
   * Run while an object is constructed.
   */
  construct {
    // Reformat the description when flags were changed.
    Utils.TextFormats.instance.update_formatting.connect (() => {
      description = Utils.TextUtils.format_text (description_modules);
      user_updated ();
    });
  }

  /**
   * Checks if the User has a certain flag set.
   */
  public bool has_flag (UserFlag flag) {
    return flag in flags;
  }

#if DEBUG
  /**
   * Returns the text modules from the description.
   *
   * Only used in test cases and therefore only available in debug builds.
   */
  public TextModule[] get_description_modules () {
    return description_modules;
  }
#endif

  /**
   * Stores the flags for this user.
   */
  protected UserFlag flags;

  /**
   * The description split into modules for formatting.
   */
  protected TextModule[] description_modules;

}
