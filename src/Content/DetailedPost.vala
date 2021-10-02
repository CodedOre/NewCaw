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
  private unowned Gtk.Box repost_status_box;
  [GtkChild]
  private unowned Gtk.Label repost_display_label;
  [GtkChild]
  private unowned Gtk.Label repost_name_label;
  [GtkChild]
  private unowned Gtk.Label repost_time_label;
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
  [GtkChild]
  private unowned Gtk.MenuButton post_options_button;

  /**
   * Creates a new DetailedPost widget displaying a specific Post.
   *
   * @param post The Post which is to be displayed in this widget.
   */
  public DetailedPost (Backend.Post post) {
    displayed_post = post;

    // Determine which post to show in main view
    bool         show_repost = false;
    Backend.Post main_post   = displayed_post;
    if (post.post_type == REPOST) {
      show_repost = true;
      main_post   = post.referenced_post;
    }

    // Set up Post information
    post_text_label.label = main_post.text;
    string date_text      = main_post.date.format ("%x, %X");
    post_info_label.label = @"$(date_text) using $(main_post.source)";

    // Set up public metrics
    post_likes_display.label   = main_post.liked_count.to_string ("%'d");
    post_reposts_display.label = main_post.reposted_count.to_string ("%'d");
    post_replies_display.label = main_post.replied_count.to_string ("%'d");

    // Set up author information
    author_display_label.label = main_post.author.display_name;
    author_name_label.label    = "@" + main_post.author.username;

    // Set up options menu
    var    post_options_menu = new Menu ();
    string open_link_label   = @"Open on $(main_post.domain)";
    string open_link_action  = @"post.open_on_domain::$(main_post.url)";
    post_options_menu.append (open_link_label, open_link_action);
    post_options_button.menu_model = post_options_menu;

    // Set up widget actions
    this.install_action ("post.open_on_domain", "s", (widget, action, arg) => {
      Gtk.show_uri (null, arg.get_string (), Gdk.CURRENT_TIME);
    });

    // If repost, display reposting user
    if (show_repost) {
      repost_display_label.label = displayed_post.author.display_name;
      repost_name_label.label    = displayed_post.author.username;
      repost_time_label.label    = DisplayUtils.display_time_delta (displayed_post.date);
      repost_status_box.visible  = true;
    }
  }

  /**
   * The displayed post.
   */
  private Backend.Post displayed_post;

}
