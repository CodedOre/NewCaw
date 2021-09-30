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
public interface Backend.Post : Object {

  /**
   * The unique identifier of this post.
   */
  public abstract string id { get; }

  /**
   * The time this post was posted.
   */
  public abstract DateTime date { get; }

  /**
   * The message of this post.
   */
  public abstract string text { owned get; }

  /**
   * The User who created this Post.
   */
  public abstract Backend.User author { get; }

  /**
   * The source application who created this Post.
   */
  public abstract string source { get; }

  /**
   * If an post is an repost or quote, this stores the post reposted or quoted.
   */
  public abstract Post? referenced_post { get; }

  /**
   * How often the post was liked.
   */
  public abstract int64 liked_count { get; }

  /**
   * How often the post was replied to.
   */
  public abstract int64 replied_count { get; }

  /**
   * How often this post was reposted or quoted.
   */
  public abstract int64 reposted_count { get; }

#if DEBUG
  /**
   * Returns the text modules.
   *
   * Only used in test cases and therefore only available in debug builds.
   */
  public abstract TextModule[] get_text_modules ();
#endif

}
