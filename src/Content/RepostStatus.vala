/* RepostStatus.vala
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
 * Displayed over an PostItem and shows the information about the reposting user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/RepostStatus.ui")]
public class RepostStatus : Gtk.Widget {

  // UI-Elements of RepostStatus
  [GtkChild]
  private unowned Adw.Bin previous_line_bin;
  [GtkChild]
  private unowned Gtk.Box information_box;
  [GtkChild]
  private unowned UserAvatar user_avatar;
  [GtkChild]
  private unowned UserButton user_button;
  [GtkChild]
  private unowned Gtk.Label time_label;

  /**
   * The repost to be displayed.
   */
  public Backend.Post repost {
    get {
      return displayed_repost;
    }
    set {
      displayed_repost = value;

      // Set the information in the UI
      user_avatar.avatar = displayed_repost != null ? displayed_repost.author.avatar : null;
      user_button.user   = displayed_repost != null ? displayed_repost.author        : null;
      time_label.label   = displayed_repost != null
                             ? DisplayUtils.display_time_delta (displayed_repost.creation_date)
                             : "(null)";
    }
  }

  /**
   * Deconstructs RepostStatus and it's childrens.
   */
  public override void dispose () {
    // Destructs children of RepostStatus
    previous_line_bin.unparent ();
    information_box.unparent ();
  }

  /**
   * Stores the displayed repost.
   */
  private Backend.Post? displayed_repost = null;
}
