/* PostStatus.vala
 *
 * Copyright 2022 Frederick Schenk
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
 * Displayed over an PostItem and shows the information about the posting user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/PostStatus.ui")]
public class PostStatus : Gtk.Widget {

  // UI-Elements of PostStatus
  [GtkChild]
  private unowned Adw.Bin previous_line_bin;
  [GtkChild]
  private unowned Gtk.Box information_box;
  [GtkChild]
  private unowned UserAvatar user_avatar;
  [GtkChild]
  private unowned UserButton user_button;
  [GtkChild]
  private unowned Gtk.Label time_spacer;
  [GtkChild]
  private unowned Gtk.Label time_label;

  /**
   * If this button is for a repost.
   */
  public bool is_repost { get; set; }

  /**
   * If the button should use the inline style.
   *
   * Also changes the label styles to use "caption".
   */
  public bool display_inline {
    get {
      return use_inline;
    }
    set {
      use_inline = value;

      // Set the size of the avatar
      user_avatar.size = use_inline ? 24 : 48;

      // Set the inline style on the button
      user_button.display_inline = use_inline;

      // Set the styles on the time spacer
      if (use_inline && ! time_spacer.has_css_class ("caption")) {
        time_spacer.add_css_class ("caption");
      }
      if (! use_inline && time_spacer.has_css_class ("caption")) {
        time_spacer.remove_css_class ("caption");
      }

      // Set the styles on the time label
      if (use_inline && ! time_label.has_css_class ("caption")) {
        time_label.add_css_class ("caption");
      }
      if (! use_inline && time_label.has_css_class ("caption")) {
        time_label.remove_css_class ("caption");
      }
    }
  }

  /**
   * The post to be displayed.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      displayed_post = value;

      // Set the information in the UI
      user_avatar.avatar = displayed_post != null ? displayed_post.author.avatar : null;
      user_button.user   = displayed_post != null ? displayed_post.author        : null;
      time_label.label   = displayed_post != null
                             ? DisplayUtils.display_time_delta (displayed_post.creation_date)
                             : "(null)";
    }
  }

  /**
   * Deconstructs PostStatus and it's childrens.
   */
  public override void dispose () {
    // Destructs children of PostStatus
    previous_line_bin.unparent ();
    information_box.unparent ();
  }

  /**
   * Stores the inline style property.
   */
  private bool use_inline = false;

  /**
   * Stores the displayed post.
   */
  private Backend.Post? displayed_post = null;
}
