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
public class Backend.Twitter.Post : Object, Backend.Post {

  /**
   * The unique identifier of this post.
   */
  public string id { get; }

  /**
   * The type of this post.
   */
  public PostType post_type { get; }

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
  public string domain {
    get {
      return "Twitter.com";
    }
  }

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
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   */
  public Post.from_json (Json.Object data, Json.Object? includes = null) {
    // Get basic data
    _id   = data.get_string_member ("id");
    _date = new DateTime.from_iso8601 (
      data.get_string_member ("created_at"),
      new TimeZone.utc ()
    );
    _source = data.get_string_member ("source");

    // Get metrics
    Json.Object metrics = data.get_object_member ("public_metrics");
    _liked_count        = metrics.get_int_member ("like_count");
    _replied_count      = metrics.get_int_member ("reply_count");
    _reposted_count     = (
      metrics.get_int_member ("retweet_count") +
      metrics.get_int_member ("quote_count")
    );

    // Parse the text into modules
    Json.Object? entities   = null;
    string       raw_text   = "";

    if (data.has_member ("text")) {
      raw_text = data.get_string_member ("text");
    }
    if (data.has_member ("entities")) {
      entities = data.get_object_member ("entities");
    }

    text_modules = TextUtils.parse_text (raw_text, entities);

    // Get the author id from this post
    if (! data.has_member ("author_id")) {
      warning ("Could not create author for this Post: Missing author_id!");
      return;
    }
    string author_id = data.get_string_member ("author_id");

    // Check if Post is a quote or repost
    string referenced_id = null;
    if (data.has_member ("referenced_tweets")) {
      // Get all referenced posts
      Json.Array references = data.get_array_member ("referenced_tweets");

      // Get the id of the reference
      references.foreach_element ((array, index, element) => {
        if (element.get_node_type () == OBJECT) {
          Json.Object obj = element.get_object ();
          referenced_id   = obj.get_string_member ("id");
          string obj_type = obj.get_string_member ("type");
          switch (obj_type) {
            case "quoted":
              _post_type = QUOTE;
              break;
            case "retweeted":
              _post_type = REPOST;
              break;
            default:
              error ("Could not create referenced_post for this Post: Unknown object type!");
          }
        }
      });
    }

    // Look for attachments
    string[] media_keys = {};
    if (data.has_member ("attachments")) {
      Json.Object attachments = data.get_object_member ("attachments");

      // Look for attached media
      if (attachments.has_member ("media_keys")) {
        Json.Array media_attachments = attachments.get_array_member ("media_keys");
          media_attachments.foreach_element ((array, index, element) => {
            if (element.get_node_type () == VALUE) {
              string next_key = element.get_string ();
              if (next_key != null) {
                media_keys += next_key;
              }
            }
          });
      }
    }

    // Look for specific objects in the includes
    Json.Object author_obj       = null;
    Json.Object reference_obj    = null;
    Backend.Media[] parsed_media = {};

    if (includes != null) {
      // Check for users in the includes
      if (includes.has_member ("users")) {
        Json.Array users_array = includes.get_array_member ("users");
        // Look in included users for author id
        users_array.foreach_element ((array, index, element) => {
          if (element.get_node_type () == OBJECT) {
            Json.Object obj = element.get_object ();
            if (obj.get_string_member("id") == author_id) {
              author_obj = obj;
            }
          }
        });
      }
      // Check for referenced posts
      if (referenced_id != null && includes.has_member ("tweets")) {
        Json.Array tweets_array = includes.get_array_member ("tweets");
        // Look in included posts for referenced id
        tweets_array.foreach_element ((array, index, element) => {
          if (element.get_node_type () == OBJECT) {
            Json.Object obj = element.get_object ();
            if (obj.get_string_member("id") == referenced_id) {
              reference_obj = obj;
            }
          }
        });
      }
      // Check for attached media
      if (media_keys.length != 0 && includes.has_member ("media")) {
        Json.Array media_jsons = includes.get_array_member ("media");
        media_jsons.foreach_element ((array, index, element) => {
          if (element.get_node_type () == OBJECT) {
            Json.Object obj = element.get_object ();
            if (obj.get_string_member("media_key") in media_keys) {
              parsed_media += Backend.Twitter.Media.create_media_from_json (obj);
            }
          }
        });
      }
    }

    // Create user object from found json
    if (author_obj != null) {
      _author = new User.from_json (author_obj);
    }

    // Create a referenced post from found json
    if (reference_obj != null) {
      _referenced_post = new Post.from_json (reference_obj, includes);
    }

    // Store the attached media
    attached_media = parsed_media;

    // Create url from author username und post id
    _url = @"https://$(domain)/$(author.username)/status/$(id)";
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
