/* PostDisplay.vala
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

public enum PostDisplayType {
  LIST,
  MAIN,
  QUOTE
}

[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/PostDisplay.ui")]
public class PostDisplay : Gtk.Box {

  // UI-Elements for the repost display
  [GtkChild]
  private unowned Gtk.Box repost_status_box;
  [GtkChild]
  private unowned Gtk.Label repost_display_label;
  [GtkChild]
  private unowned Gtk.Label repost_name_label;
  [GtkChild]
  private unowned Gtk.Label repost_time_label;

  // UI-Elements for the post information
  [GtkChild]
  private unowned Adw.Avatar author_avatar;
  [GtkChild]
  private unowned Gtk.Label author_display_label;
  [GtkChild]
  private unowned Gtk.Label author_name_label;
  [GtkChild]
  private unowned Gtk.Label post_info_label;
  [GtkChild]
  private unowned Gtk.Label post_time_label;

  // UI-Elements for the text
  [GtkChild]
  private unowned Gtk.Label post_text_label;

  // UI-Elements for the additional content
  [GtkChild]
  private unowned MediaPreview media_previewer;
  [GtkChild]
  private unowned Gtk.ListBox quote_container;

  // UI-Elements for the post metrics
  [GtkChild]
  private unowned Gtk.Box post_metrics_box;
  [GtkChild]
  private unowned Gtk.Label post_likes_display_label;
  [GtkChild]
  private unowned Gtk.Label post_reposts_display_label;
  [GtkChild]
  private unowned Gtk.Label post_replies_display_label;

  // UI-Elements for the action box
  [GtkChild]
  private unowned Gtk.Box post_actions_box;
  [GtkChild]
  private unowned Adw.ButtonContent post_like_button_display;
  [GtkChild]
  private unowned Adw.ButtonContent post_repost_button_display;
  [GtkChild]
  private unowned Adw.ButtonContent post_reply_button_display;
  [GtkChild]
  private unowned Gtk.MenuButton post_options_button;

  /**
   * Creates a new PostDisplay widget displaying a specific Post.
   *
   * @param post The Post which is to be displayed in this widget.
   */
  public PostDisplay (Backend.Post post, PostDisplayType display_type = LIST) {
    // Store the post to display
    displayed_post = post;

    // Determine which post to show in main view
    bool show_repost = false;
    if (post.post_type == REPOST) {
      show_repost = true;
      main_post   = post.referenced_post;
    } else {
      main_post = displayed_post;
    }

    // Set up the repost display
    if (show_repost) {
      repost_display_label.label = displayed_post.author.display_name;
      repost_name_label.label    = "@" + displayed_post.author.username;
      repost_time_label.label    = DisplayUtils.display_time_delta (displayed_post.date);
      repost_status_box.visible  = true;
    }

    // Hint for the user where the post can be opened in the browser
    string open_link_label = _("Open on %s").printf (main_post.domain);

    // Set up the post information area
    if (display_type == MAIN) {
      // Set up author side-by-side when main display
      author_display_label.label = main_post.author.display_name;
      author_name_label.label    = "@" + main_post.author.username;

      // Add date and source to info label
      string date_text      = main_post.date.format ("%x, %X");
      post_info_label.label = _("%s using %s").printf (date_text, main_post.source);
    } else {
      // Set up author top-and-bottom when list display
      author_display_label.label = main_post.author.display_name;
      post_info_label.label      = "@" + main_post.author.username;

      // Add relative date and link to page in corner
      string post_time_text = DisplayUtils.display_time_delta (main_post.date);
      post_time_label.label = @"<a href=\"$(main_post.url)\" title=\"$(open_link_label)\" class=\"weblink\">$(post_time_text)</a>";
    }

    // Display post message in main label
    post_text_label.label      = main_post.text;
    post_text_label.selectable = display_type == MAIN;

    // Display media if post contains some
    if (main_post.get_media ().length > 0) {
      media_previewer.display_media (main_post.get_media ());
      media_previewer.visible = true;
    }

    // Display quote if not itself quote display
    if (main_post.post_type == QUOTE && display_type != QUOTE) {
      var quote_post = new PostDisplay (main_post.referenced_post, QUOTE);
      quote_container.append (quote_post);
      quote_container.visible = true;
    }

    // Make the UI smaller in a quote display
    if (display_type == QUOTE) {
      post_text_label.set_css_classes ({ "caption" });
      post_time_label.set_css_classes ({ "caption" });
      author_display_label.set_css_classes ({ "caption-heading" });
      author_avatar.size = 32;
    }

    // Set up either metrics or action box
    if (display_type == MAIN) {
      // Set up action box
      post_actions_box.visible = true;

      // Set up metrics in buttons
      post_like_button_display.label   = main_post.liked_count.to_string ("%'d");
      post_repost_button_display.label = main_post.reposted_count.to_string ("%'d");
      post_reply_button_display.label  = main_post.replied_count.to_string ("%'d");

      // Set up options menu
      var    post_options_menu = new Menu ();
      string open_link_action  = @"post_display.open_link::$(main_post.url)";
      post_options_menu.append (open_link_label, open_link_action);
      post_options_button.menu_model = post_options_menu;
    } else {
      // Set up metrics box
      post_metrics_box.visible = true;

      // Set up metrics labels
      post_likes_display_label.label   = main_post.liked_count.to_string ("%'d");
      post_reposts_display_label.label = main_post.reposted_count.to_string ("%'d");
      post_replies_display_label.label = main_post.replied_count.to_string ("%'d");
    }

    // Set up "Open link" action
    this.install_action ("post_display.open_link", "s", (widget, action, arg) => {
      Gtk.show_uri (null, arg.get_string (), Gdk.CURRENT_TIME);
    });

    // Set up "display media" action
    this.install_action ("post_display.display_media", "i", (widget, action, arg) => {
      // TODO: Open MediaDisplay with media using MainWindow
    });
  }

  /**
   * The displayed post.
   */
  private Backend.Post displayed_post;

  /**
   * The post displayed in the main view.
   */
  private Backend.Post main_post;

}
