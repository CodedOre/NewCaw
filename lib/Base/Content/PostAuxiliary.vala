/* PostAuxiliary.vala
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
 * Different types for a Post.
 *
 * Determines some settings when displaying this particular post.
 */
public enum Backend.PostType {
  /**
   * Your normal day-to-day post.
   */
  NORMAL,
  /**
   * A repost from an different post.
   */
  REPOST,
  /**
   * A repost with additional content added.
   */
  QUOTE
}

/**
 * The sensitivity of the content of a post.
 *
 * Determines what of the content should be displayed directly.
 */
public enum Backend.PostSensitivity {
  /**
   * Nothing has to be hidden.
   */
  NONE,
  /**
   * Only the media is sensitive.
   */
  MEDIA,
  /**
   * All content is sensitive.
   */
  ALL
}

/**
 * Stores interaction data to update a post with.
 *
 * Used by Session to update the data of an post when an
 * API call altered the interaction data values.
 */
internal struct Backend.PostInteractionData {
  int liked_count;
  int replied_count;
  int reposted_count;
  bool is_favourited;
  bool is_reposted;
}
