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
  [GtkChild]
  private unowned Gtk.Label post_info_label;
  [GtkChild]
  private unowned Gtk.Label author_display_label;
  [GtkChild]
  private unowned Gtk.Label author_name_label;
  [GtkChild]
  private unowned Adw.ButtonContent post_likes_display;
  [GtkChild]
  private unowned Adw.ButtonContent post_reposts_display;
  [GtkChild]
  private unowned Adw.ButtonContent post_replies_display;

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
    string date_text = displayed_post.date.format ("%x, %X");
    post_info_label.label = @"$(date_text) using $(displayed_post.source)";

    // Set up public metrics
    post_likes_display.label   = displayed_post.liked_count.to_string ();
    post_reposts_display.label = displayed_post.reposted_count.to_string ();
    post_replies_display.label = displayed_post.replied_count.to_string ();

    // Set up author information
    author_display_label.label = displayed_post.author.display_name;
    author_name_label.label    = "@" + displayed_post.author.username;
  }

  /**
   * The displayed post.
   */
  private Backend.Post displayed_post;

}
