/* UserButton.vala
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
 * A button displaying the name of an user in a PostItem.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/UserButton.ui")]
public class UserButton : Gtk.Button {

  // UI-Elements of UserButton
  [GtkChild]
  private unowned Gtk.Box button_content;
  [GtkChild]
  private unowned Gtk.Label display_label;
  [GtkChild]
  private unowned BadgesBox user_badges;
  [GtkChild]
  private unowned Gtk.Label username_label;

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

      // Set the css for the widgets
      DisplayUtils.conditional_css (use_inline,   this,           "inline");
      DisplayUtils.conditional_css (use_inline,   display_label,  "caption-heading");
      DisplayUtils.conditional_css (use_inline,   username_label, "caption");
      DisplayUtils.conditional_css (! use_inline, display_label,  "heading");
      DisplayUtils.conditional_css (! use_inline, username_label, "body");
    }
  }

  /**
   * The user displayed in this button.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      displayed_user = value;

      // Set the UI elements to the user
      display_label.label           = displayed_user != null ? displayed_user.display_name         : "(null)";
      username_label.label          = displayed_user != null ? "@" + displayed_user.username       : "(null)";
      user_badges.display_verified  = displayed_user != null ? displayed_user.has_flag (VERIFIED)  : false;
      user_badges.display_bot       = displayed_user != null ? displayed_user.has_flag (BOT)       : false;
      user_badges.display_protected = displayed_user != null ? displayed_user.has_flag (PROTECTED) : false;
    }
  }

  /**
   * Deconstructs UserButton and it's childrens.
   */
  public override void dispose () {
    // Destructs children of UserButton
    button_content.unparent ();
    base.dispose ();
  }

  /**
   * Stores the inline style property.
   */
  private bool use_inline = false;

  /**
   * Stores the displayed user.
   */
  private Backend.User? displayed_user = null;

}
