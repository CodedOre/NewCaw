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
public class Backend.Mastodon.Post : Backend.Post {

  /**
   * Returns a Post object for a given Json.Object.
   *
   * If an object for the post was already created, that object is returned.
   * Otherwise a new object will be created from the json object.
   *
   * @param json The Json.Object containing the specific Post.
   */
  public static Post from_json (Json.Object json) {
    // Initialize the storage if needed
    if (all_posts == null) {
      all_posts = new HashTable <string, Post> (str_hash, str_equal);
    }

    // Attempt to retrieve the user from storage
    string url    = json.get_string_member ("url");
    string domain = Utils.ParseUtils.strip_domain (url);
    string name   = json.get_string_member ("id");
    string id     = @"$(name)@$(domain)";
    Post?  post = all_posts.contains (id)
                    ? all_posts [id]
                    : null;

    // Create new object if not in storage
    if (post == null) {
      post = new Post (json);
      all_posts [id] = post;
    }

    // Return the object
    return post;
  }

  /**
   * Parses an given Json.Object and creates an Post object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  private Post (Json.Object json) {
    // Get url to html site if available
    string post_url = ! json.get_null_member ("url")
                        ? json.get_string_member ("url")
                        : json.get_string_member ("uri");
    string post_domain = Utils.ParseUtils.strip_domain (post_url);

    // Construct object with properties
    Object (
      // Set basic data
      id:       json.get_string_member ("id"),
      source: ! json.get_null_member ("application")
                ? json.get_object_member ("application").get_string_member ("name")
                : "Undefined",
      creation_date: new DateTime.from_iso8601 (
                       json.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set PostType
      post_type: json.get_null_member ("reblog") ? PostType.NORMAL : PostType.REPOST,

      // Set url and domain
      url:    post_url,
      domain: post_domain,

      // Set metrics
      liked_count:    (int) json.get_int_member ("favourites_count"),
      replied_count:  (int) json.get_int_member ("replies_count"),
      reposted_count: (int) json.get_int_member ("reblogs_count"),

      // Set the author
      author: User.from_json (json.get_object_member ("account")),

      // Set replied_to_id
      replied_to_id: ! json.get_null_member ("in_reply_to_id")
                       ? json.get_string_member ("in_reply_to_id")
                       : null
    );

    // Parse the text into modules
    text_modules = Utils.TextParser.instance.parse_text (json.get_string_member ("content"));

    // First format of the text.
    text = Backend.Utils.TextUtils.format_text (text_modules);

    // Set the referenced post
    referenced_post = ! json.get_null_member ("reblog")
                        ? Post.from_json (json.get_object_member ("reblog"))
                        : null;

    // Get media attachments
    Backend.Media[] parsed_media = {};
    Json.Array      media_jsons  = json.get_array_member ("media_attachments");
    media_jsons.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        Json.Object obj    = element.get_object ();
        parsed_media += Backend.Mastodon.Media.from_json (obj);
      }
    });
    attached_media = parsed_media;
  }

  /**
   * Returns a possible post that this post referenced.
   *
   * If the referenced post is not in local memory,
   * it will load said post from the servers.
   *
   * @param account An account to authenticate a possible loading of the post.
   *
   * @return The post referenced or null if none exists.
   *
   * @throw Error Any error that might happen while loading the post.
   */
  public override async Backend.Post? get_referenced_post (Backend.Account account) throws Error {
    return referenced_post;
  }

  /**
   * Stores a reference to each post currently in memory.
   */
  private static HashTable <string, Post> all_posts;

  /**
   * Stores the referenced post.
   */
  private Post? referenced_post;

}
