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
public abstract class Backend.Post : Object {

  /**
   * The session this post is managed by and to be used to retrieve additional data.
   */
  public Session session { get; construct; }

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
  public DateTime creation_date { get; construct; }

  /**
   * The message of this post.
   */
  public string text { get; protected set; }

  /**
   * The User who created this Post.
   */
  public Backend.User author { get; construct; }

  /**
   * The source application who created this Post.
   */
  public string source { get; construct; }

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
   * The id for the post this post replies to.
   */
  public string? replied_to_id { get; construct; }

  /**
   * Emitted when data in this post has changed.
   */
  public signal void post_updated ();

  /**
   * Run while an object is constructed.
   */
  construct {
    // Reformat the text when flags were changed.
    Utils.TextFormats.instance.update_formatting.connect (() => {
      text = Utils.TextUtils.format_text (text_modules);
      post_updated ();
    });
  }

  /**
   * Returns a possible post that this post referenced.
   *
   * If the referenced post is not in local memory,
   * it will load said post from the servers.
   *
   * @return The post referenced or null if none exists.
   *
   * @throws Error Any error that might happen while loading the post.
   */
  public abstract async Post? get_referenced_post () throws Error;

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
  protected Backend.Media[] attached_media;

  /**
   * The text split into modules for formatting.
   */
  protected TextModule[] text_modules;

}
