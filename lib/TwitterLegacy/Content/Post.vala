/* Post.vala
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
 * Represents one posted status message.
 */
public class Backend.TwitterLegacy.Post : Object, Backend.Post {

  /**
   * The unique identifier of this post.
   */
  public string id { get; }

  /**
   * The time this post was posted.
   */
  public DateTime date { get; }

  /**
   * The message of this post.
   */
  public string text { get; }

  /**
   * How often the post was liked.
   */
  public int64 liked_count { get; }

  /**
   * How often the post was replied to.
   */
  public int64 replied_count { get; }

  /**
   * How often this post was reposted or quoted.
   */
  public int64 reposted_count { get; }

  /**
   * Parses an given Json.Object and creates an Post object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public Post.from_json (Json.Object json) {
    // Get basic data
    _id   = json.get_string_member ("id_str");
    _date = parse_time (json.get_string_member ("created_at"));

    // Get metrics
    _liked_count    = json.get_int_member ("favorite_count");
    // TODO: Add `replied_count` by counting actual replies
    _reposted_count = json.get_int_member ("retweet_count");

  /**
   * Formats the raw-text for the use in the UI.
   */
  private void format_text () {
  }

  /**
   * Parses the custom date string to a valid GLib.DateTime.
   *
   * @param text The date from the API to be converted.
   *
   * @return A GLib.DateTime with the date from the string.
   */
  private DateTime parse_time (string text) {
    // Initialize variables
    GLib.TimeZone zone = new GLib.TimeZone.utc ();
    int year, month, day, hour, minute;
    double second;

    // Check if string is valid
    if (text.length != 30) {
      // Return January 1th 2000 as default value
      warning ("Parser encountered invalid date string!");
      return new GLib.DateTime (zone, 2000, 1, 1, 0, 0, 0);
    }

    // Parse numbers from string
    year   = int.parse    (text.substring (26, 4));
    day    = int.parse    (text.substring ( 8, 2));
    hour   = int.parse    (text.substring (11, 2));
    minute = int.parse    (text.substring (14, 2));
    second = double.parse (text.substring (17, 2));

    // Parse three character month indication from string
    switch (text.substring (4, 3)) {
      case "Jan":
        month = 1;
        break;
      case "Feb":
        month = 2;
        break;
      case "Mar":
        month = 3;
        break;
      case "Apr":
        month = 4;
        break;
      case "May":
        month = 5;
        break;
      case "Jun":
        month = 6;
        break;
      case "Jul":
        month = 7;
        break;
      case "Aug":
        month = 8;
        break;
      case "Sep":
        month = 9;
        break;
      case "Oct":
        month = 10;
        break;
      case "Nov":
        month = 11;
        break;
      case "Dec":
        month = 12;
        break;
      default:
        warning ("Parser encountered invalid date string!");
        return new GLib.DateTime (zone, 2000, 1, 1, 0, 0, 0);
    }

    // Return DateTime with new values.
    GLib.DateTime result = new GLib.DateTime (zone, year, month, day, hour, minute, second);
    if (result == null) {
      warning ("Parser encountered invalid date string!");
      return new GLib.DateTime (zone, 2000, 1, 1, 0, 0, 0);
    }
    return result;
  }

  /**
   * The text split into modules for formatting.
   */
  private TextModule[] text_modules;

}
