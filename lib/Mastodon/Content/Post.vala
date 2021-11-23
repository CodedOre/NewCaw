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
public class Backend.Mastodon.Post : Object, Backend.Post {

  /**
   * The unique identifier of this post.
   */
  public string id { get; construct; }

  /**
   * The type of this post.
   */
  public PostType post_type { get; construct; }

  /**
   * The time this post was posted.
   */
  public DateTime date { get; construct; }

  /**
   * The message of this post.
   */
  public string text {
    owned get {
      return Backend.TextUtils.format_text (text_modules);
    }
  }

  /**
   * The User who created this Post.
   */
  public Backend.User author { get; construct; }

  /**
   * The website where this post originates from.
   */
  public string domain { get; construct; }

  /**
   * The url to visit this post on the original website.
   */
  public string url { get; construct; }

  /**
   * The source application who created this Post.
   */
  public string source { get; construct; }

  /**
   * If an post is an repost or quote, this stores the post reposted or quoted.
   */
  public Backend.Post? referenced_post { get; construct; }

  /**
   * How often the post was liked.
   */
  public int liked_count { get; construct; }

  /**
   * How often the post was replied to.
   */
  public int replied_count { get; construct; }

  /**
   * How often this post was reposted or quoted.
   */
  public int reposted_count { get; construct; }

  /**
   * Parses an given Json.Object and creates an Post object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public Post.from_json (Json.Object json) {
    // Get url to html site if available
    string post_url;
    if (! json.get_null_member ("url")) {
      post_url = json.get_string_member ("url");
    } else {
      post_url = json.get_string_member ("uri");
    }

    // Get domain from the url
    string post_domain;
    try {
      var domain_regex = new Regex ("https?://(.*?)/.*");
      post_domain = domain_regex.replace (
        post_url,
        post_url.length,
        0,
        "\\1"
      );
    } catch (RegexError e) {
      error (@"Error while parsing domain: $(e.message)");
    }

    // Construct object with properties
    Object (
      // Set basic data
      id:   json.get_string_member ("id"),
      date: new DateTime.from_iso8601 (
              json.get_string_member ("created_at"),
              new TimeZone.utc ()
            ),
      source: ! json.get_null_member ("application")
                ? json.get_object_member ("application").get_string_member ("name")
                : "Undefined",

      // Set url and domain
      url:    post_url,
      domain: post_domain,

      // Set metrics
      liked_count:    (int) json.get_int_member ("favourites_count"),
      replied_count:  (int) json.get_int_member ("replies_count"),
      reposted_count: (int) json.get_int_member ("reblogs_count"),

      // Set the author
      author: new User.from_json (json.get_object_member ("account")),

      // Set PostType and referenced post
      post_type: json.get_null_member ("reblog") ? PostType.NORMAL : PostType.REPOST,
      referenced_post: ! json.get_null_member ("reblog")
                         ? new Post.from_json (json.get_object_member ("reblog"))
                         : null
    );

    // Parse the text into modules
    text_modules = TextUtils.parse_text (json.get_string_member ("content"));

    // Get media attachments
    Backend.Media[] parsed_media = {};
    Json.Array      media_jsons  = json.get_array_member ("media_attachments");
    media_jsons.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        Json.Object obj    = element.get_object ();
        parsed_media += Backend.Mastodon.Media.create_media_from_json (obj);
      }
    });
    attached_media = parsed_media;
  }

  /**
   * Returns media attached to this Post.
   */
  public Backend.Media[] get_media () {
    return attached_media;
  }

#if DEBUG
  /**
   * Returns the text modules.
   *
   * Only used in test cases and therefore only available in debug builds.
   */
  public TextModule[] get_text_modules () {
    return text_modules;
  }
#endif

  /**
   * All media attached to this post.
   */
  public Backend.Media[] attached_media;

  /**
   * The text split into modules for formatting.
   */
  private TextModule[] text_modules;

}
