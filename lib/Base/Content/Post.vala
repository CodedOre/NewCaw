/* Post.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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
   * The sensitivity of the content.
   */
  public PostSensitivity sensitive { get; construct; }

  /**
   * A short text describing the content for sensitive post.
   */
  public string spoiler { get; construct; }

  /**
   * A post this one references when it is a repost.
   */
  public Post? referenced_post { get; construct; }

  /**
   * How often the post was liked.
   */
  public int liked_count { get; protected construct set; }

  /**
   * How often the post was replied to.
   */
  public int replied_count { get; protected construct set; }

  /**
   * How often this post was reposted or quoted.
   */
  public int reposted_count { get; protected construct set; }

  /**
   * The id for the post this post replies to.
   */
  public string? replied_to_id { get; construct; }

  /**
   * Whether the post has been favourited by the session user
   */
  public bool is_favourited { get; protected construct set; default = false; }

  /**
   * Whether the post has been reblogged by the session user
   */
   public bool is_reposted { get; protected construct set; default = false; }

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
   * Favourite/like this post.
   *
   * Adds the favourite/like/platform-equivalent flag to the post. If the post
   * is already favourited/liked then this is a noop and no exception will be thrown.
   *
   * @return This post object, which may have been updated if the platform supports it
   * @throws Error Any errors while favouriting, such as unauthorised actions, missing posts, or network issues
   */
  public async Backend.Post favourite () throws Error {
    return yield this.session.favourite_post (this);
  }

  /**
   * Unfavourite/unlike this post.
   *
   * Removes the favourite/like/platform-equivalent flag from the post. If the post
   * is not favourited/liked then this is a noop and no exception will be thrown.
   *
   * @return This post object, which may have been updated if the platform supports it
   * @throws Error Any errors while unfavouriting, such as unauthorised actions, missing posts, or network issues
   */
   public async Backend.Post unfavourite () throws Error {
    return yield this.session.unfavourite_post (this);
   }

  /**
   * Reblogs/boosts/retweets this post.
   *
   * Reblogs the post to the user's timeline. If the post is already reblogged then this is a noop
   * and no exception will be thrown.
   *
   * @return A Post object representing the reposted post in the user's timeline (if provided by the platform)
   *
   * @throws Error Any errors while reblogging, such as unauthorised actions, missing posts, or network issues
   */
   public async Backend.Post? reblog () throws Error {
    return yield this.session.reblog_post (this);
   }

  /**
   * Un-reblogs/unboosts/un-retweets this post.
   *
   * Removes the reblog from the user's timeline. If the post is not reblogged then this is a noop
   * and no exception will be thrown.
   *
   * @return the unreblogged post (if available)
   * @throws Error Any errors while un-reblogging, such as unauthorised actions, missing posts, or network issues
   */
   public async Backend.Post? unreblog () throws Error {
    return yield this.session.unreblog_post (this);
   }

   /*
    * Updates interaction data that may change over time
    *
    * @param A struct holding the new interaction data
    */
   internal void update_interactions (PostInteractionData data) {
    this.liked_count = data.liked_count;
    this.replied_count = data.replied_count;
    this.reposted_count = data.reposted_count;
    this.is_favourited = data.is_favourited;
    this.is_reposted = data.is_reposted;
    post_updated();
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
  protected Backend.Media[] attached_media;

  /**
   * The text split into modules for formatting.
   */
  protected TextModule[] text_modules;

}
