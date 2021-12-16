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

public class Backend.Mastodon.Profile : Backend.Mastodon.User, Backend.Profile {

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
  public Backend.Picture header { get; construct; }

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
   * Parses an given Json.Object and creates an Profile object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public Profile.from_json (Json.Object json) {
    // Get the url for avatar and header
    string avatar_url = json.get_string_member ("avatar_static");
    string header_url = json.get_string_member ("header_static");

    // Get url and domain to this profile
    string profile_url = json.get_string_member ("url");
    string profile_domain;
    try {
      var domain_regex = new Regex ("https?://(.*?)/.*");
      profile_domain = domain_regex.replace (
        profile_url,
        profile_url.length,
        0,
        "\\1"
      );
    } catch (RegexError e) {
      error (@"Error while parsing domain: $(e.message)");
    }

    // Construct the object with properties
    Object (
      // Set the id of the profile
      id: json.get_string_member ("id"),

      // Set the creation date for the profile
      creation_date: new DateTime.from_iso8601 (
                       json.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set the names of the profile
      display_name: json.get_string_member ("display_name"),
      username:     json.get_string_member ("username"),

      // Set the url and domain
      url:    profile_url,
      domain: profile_domain,

      // Set metrics
      followers_count: (int) json.get_int_member ("followers_count"),
      following_count: (int) json.get_int_member ("following_count"),
      posts_count:     (int) json.get_int_member ("statuses_count"),

      // Set the images
      avatar: new Picture (avatar_url),
      header: new Picture (header_url)
    );

    // Parse the description into modules
    description_modules = TextUtils.parse_text (json.get_string_member ("note"));

    // Parses all fields
    UserDataField[] parsed_fields = {};
    Json.Array profile_fields     = json.get_array_member ("fields");
    profile_fields.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        // Create an data field object
        Json.Object obj = element.get_object ();
        var new_field   = UserDataField ();
        new_field.type  = GENERIC;
        new_field.name  = obj.get_string_member ("name");
        // Check if field contains weblink
        try {
          var link_regex = new Regex ("<a href=\"(.*?)\" rel=\".*?\" target=\"_blank\"><span class=\"invisible\">.*?</span><span class=\"\">(.*?)</span><span class=\"invisible\"></span></a>");
          if (link_regex.match (obj.get_string_member ("value"))) {
            new_field.display = link_regex.replace (obj.get_string_member ("value"), obj.get_string_member ("value").length, 0, "\\2");
            new_field.target  = link_regex.replace (obj.get_string_member ("value"), obj.get_string_member ("value").length, 0, "\\1");
          } else {
            new_field.display = obj.get_string_member ("value");
            new_field.target  = null;
          }
        } catch (RegexError e) {
          error (@"Error while parsing data fields: $(e.message)");
        }
        // Append field to the array
        parsed_fields  += new_field;
      }
    });
    data_fields = parsed_fields;

    // Get possible flags for this user
    if (json.get_boolean_member ("locked")) {
      flags = flags | MODERATED;
    }
    if (json.get_boolean_member ("bot")) {
      flags = flags | BOT;
    }
  }

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
  public UserDataField[] data_fields;

  /**
   * The description split into modules for formatting.
   */
  private TextModule[] description_modules;

}
