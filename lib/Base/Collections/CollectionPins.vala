/* CollectionPins.vala
 *
 * Copyright 2023 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * An interface for Collection providing pinned posts.
 */
public interface Backend.CollectionPins : Backend.Collection<Object> {

  /**
   * Checks if an post in the collection was pinned by the user.
   *
   * If the post is not in this collection, the method returns false.
   *
   * @param post The post to check for.
   *
   * @return If the checked post was pinned by the user of this timeline.
   */
  public abstract bool is_pinned_post (Post post);

}
