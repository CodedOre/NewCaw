/* DetailedPost.vala
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

[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/DetailedPost.ui")]
public class DetailedPost : Gtk.Box {

  // UI-Elements of DetailedPost
  [GtkChild]
  private unowned Gtk.Label post_text_label;

  /**
   * Creates a new DetailedPost widget displaying a specific Post.
   *
   * @param post The Post which is to be displayed in this widget.
   */
  public DetailedPost (Backend.Post post) {
    // Set up displayed post
    displayed_post = post;

    // Set up Post information
    post_text_label.label = displayed_post.text;
  }

  /**
   * The displayed post.
   */
  private Backend.Post displayed_post;

}
