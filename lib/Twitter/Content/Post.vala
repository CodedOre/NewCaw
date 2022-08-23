/* Post.vala
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
 * Represents one posted status message.
 */
public class Backend.Twitter.Post : Backend.Post {

  /**
   * Parses an given Json.Object and creates an Post object.
   *
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   */
  public Post.from_json (Json.Object data, Json.Object includes) {
    // Get metrics object
    Json.Object metrics = data.get_object_member ("public_metrics");

    // Get author and referenced json
    Json.Object? referenced_obj;
    Json.Object? author_obj    = parse_author (data, includes);
    PostType     set_post_type = parse_reference (data, includes, out referenced_obj);

    // Get strings used to compose the url.
    var    post_author = author_obj  != null ? User.from_json (author_obj) : null;
    string author_name = post_author != null ? post_author.username : "";
    string post_id     = data.get_string_member ("id");

    // Construct object with properties
    Object (
      // Set basic data
      id:        post_id,
      source:    data.get_string_member ("source"),
      post_type: set_post_type,
      creation_date: new DateTime.from_iso8601 (
                       data.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set url and domain
      domain: "Twitter.com",
      url:    @"https://twitter.com/$(author_name)/status/$(post_id)",

      // Set public metrics
      liked_count:    (int) metrics.get_int_member ("like_count"),
      replied_count:  (int) metrics.get_int_member ("reply_count"),
      reposted_count: (int) metrics.get_int_member ("retweet_count")
                    + (int) metrics.get_int_member ("quote_count"),

      // Set referenced objects
      author:          post_author,
      referenced_post: referenced_obj != null ? new Post.from_json (referenced_obj, includes) : null
    );

    // Parse text into modules
    Json.Object? entities   = null;
    string       raw_text   = "";
    if (data.has_member ("text")) {
      raw_text = data.get_string_member ("text");
    }
    if (data.has_member ("entities")) {
      entities = data.get_object_member ("entities");
    }
    text_modules = Utils.TextUtils.parse_text (raw_text, entities);

    // First format of the text.
    text = Backend.Utils.TextUtils.format_text (text_modules);

    // Retrieve the attached media for this Post
    attached_media = parse_media (data, includes);
  }

  /**
   * Parses the includes for the Json.Object for the author of this post.
   *
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   *
   * @return A Json.Object with the json of the author, to be used to construct a User.
   */
  private static Json.Object? parse_author (Json.Object data, Json.Object includes) {
    // Get the author id from this post
    if (! data.has_member ("author_id")) {
      error ("Could not create author for this Post: Missing author_id!");
    }
    string author_id = data.get_string_member ("author_id");

    // Get the json object from the includes
    Json.Object author_obj = null;
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

    if (author_obj != null) {
      // Return the parsed object
      return author_obj;
    } else {
      // Fail the parsing if author not found
      error ("Could not create author for this Post: No object found in includes!");
    }
  }

  /**
   * Parses the includes for the Json.Object for the referenced post.
   *
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   * @param parsed_obj A parameter in which the referenced post will be returned.
   *
   * @return The PostType the parsed post should be assigned.
   */
  private static PostType parse_reference (Json.Object data, Json.Object includes, out Json.Object? parsed_obj = null) {
    // Check if Post is a quote or repost
    PostType     returned_type = NORMAL;
    Json.Object? returned_obj  = null;
    string       referenced_id = null;
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
              returned_type = QUOTE;
              break;
            case "retweeted":
              returned_type = REPOST;
              break;
            case "replied_to":
              break;
            default:
              error ("Could not create referenced_post for this Post: Unknown object type!");
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
            returned_obj = obj;
          }
        }
      });
    }

    // Return the PostType
    parsed_obj = returned_obj;
    return returned_type;
  }

  /**
   * Parses the includes for the Json.Object for attached media for this post.
   *
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   *
   * @return A Json.Object with the Media objects for this post.
   */
  private static Backend.Media[] parse_media (Json.Object data, Json.Object includes) {
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
    Backend.Media[] parsed_media = {};

    if (includes != null) {
      // Check for attached media
      if (media_keys.length != 0 && includes.has_member ("media")) {
        Json.Array media_jsons = includes.get_array_member ("media");
        media_jsons.foreach_element ((array, index, element) => {
          if (element.get_node_type () == OBJECT) {
            Json.Object obj = element.get_object ();
            if (obj.get_string_member("media_key") in media_keys) {
              parsed_media += new Backend.Twitter.Media.from_json (obj);
            }
          }
        });
      }
    }

    // Store the attached media
    return parsed_media;
  }

}
