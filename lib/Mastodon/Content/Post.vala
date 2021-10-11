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
  public string id { get; }

  /**
   * The type of this post.
   */
  public PostType post_type { get; default = NORMAL; }

  /**
   * The time this post was posted.
   */
  public DateTime date { get; }

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
  public Backend.User author { get; }

  /**
   * The website where this post originates from.
   */
  public string domain { get; }

  /**
   * The url to visit this post on the original website.
   */
  public string url { get; }

  /**
   * The source application who created this Post.
   */
  public string source { get; }

  /**
   * If an post is an repost or quote, this stores the post reposted or quoted.
   */
  public Backend.Post? referenced_post { get; }

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
    _id   = json.get_string_member ("id");
    _date = new DateTime.from_iso8601 (
      json.get_string_member ("created_at"),
      new TimeZone.utc ()
    );

    // Get the application name if available
    if (! json.get_null_member ("application")) {
      Json.Object application = json.get_object_member ("application");
      _source = application.get_string_member ("name");
    } else {
      _source = "Undefined";
    }

    // Get metrics
    _liked_count    = json.get_int_member ("favourites_count");
    _replied_count  = json.get_int_member ("replies_count");
    _reposted_count = json.get_int_member ("reblogs_count");

    // Parse the text into modules
    text_modules = TextUtils.parse_text (json.get_string_member ("content"));

    // Get the creator of this Post
    Json.Object user_obj = json.get_object_member ("account");
    _author = new User.from_json (user_obj);

    // If this is a boost, create a referenced post
    if (! json.get_null_member ("reblog")) {
      Json.Object original_post = json.get_object_member ("reblog");
      _referenced_post = new Post.from_json (original_post);
      _post_type       = REPOST;
    }

    // Get url to html site if available
    if (! json.get_null_member ("url")) {
      _url = json.get_string_member ("url");
    } else {
      _url = json.get_string_member ("uri");
    }
    // Get domain from the url
    try {
      var domain_regex = new Regex ("https?://(.*?)/.*");
      _domain = domain_regex.replace (
        url,
        url.length,
        0,
        "\\1"
      );
    } catch (RegexError e) {
      error (@"Error while parsing domain: $(e.message)");
    }
  }

  /**
   * Returns media attached to this Post.
   */
  public Media[] get_media () {
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
  public Media[] attached_media;

  /**
   * The text split into modules for formatting.
   */
  private TextModule[] text_modules;

}
