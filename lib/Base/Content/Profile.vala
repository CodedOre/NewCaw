/* Profile.vala
 *
 * Copyright 2021 Frederick Schenk
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
public interface Backend.Profile : Backend.User {

  /**
   * When this Profile was created on the platform.
   */
  public abstract DateTime creation_date { get; construct; }

  /**
   * A formatted description set for the Profile.
   */
  public abstract string description { owned get; }

  /**
   * The header image for the detail page of this user.
   */
  public abstract Picture header { get; construct; }

  /**
   * How many people are following this Profile.
   */
  public abstract int followers_count { get; construct; }

  /**
   * How many people this Profile follows.
   */
  public abstract int following_count { get; construct; }

  /**
   * How many posts this Profile wrote.
   */
  public abstract int posts_count { get; construct; }

  /**
   * The website where this post originates from.
   *
   * Mostly important for the Mastodon backend, where a post
   * can come from multiple site thanks to the federation.
   */
  public abstract string domain { get; construct; }

  /**
   * The url to visit this post on the original website.
   */
  public abstract string url { get; construct; }

  /**
   * Retrieves the UserDataFields for this Profile.
   */
  public abstract UserDataField[] get_data_fields ();

}
