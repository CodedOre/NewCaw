/* Profile.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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
 * Extends User with additional information not contained there.
 *
 * Used when displaying a User in detail.
 */
public abstract class Backend.Profile : Backend.User {

  /**
   * When this Profile was created on the platform.
   */
  public DateTime creation_date { get; construct; }

  /**
   * A formatted description set for the Profile.
   */
  public string description {
    owned get {
      return Backend.TextUtils.format_text (description_modules);
    }
  }

  /**
   * The header image for the detail page of this user.
   */
  public Media header { get; construct; }

  /**
   * How many people are following this Profile.
   */
  public int followers_count { get; construct; }

  /**
   * How many people this Profile follows.
   */
  public int following_count { get; construct; }

  /**
   * How many posts this Profile wrote.
   */
  public int posts_count { get; construct; }

  /**
   * The website where this post originates from.
   *
   * Mostly important for the Mastodon backend, where a post
   * can come from multiple site thanks to the federation.
   */
  public string domain { get; construct; }

  /**
   * The url to visit this post on the original website.
   */
  public string url { get; construct; }

  /**
   * Retrieves the UserDataFields for this Profile.
   */
  public UserDataField[] get_data_fields () {
    return data_fields;
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
   * All data fields attached to this post.
   */
  protected UserDataField[] data_fields;

  /**
   * The description split into modules for formatting.
   */
  protected TextModule[] description_modules;

}
