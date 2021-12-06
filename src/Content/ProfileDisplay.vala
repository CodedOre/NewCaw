/* ProfileDisplay.vala
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
 * Displays an overview over an Profile.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/ProfileDisplay.ui")]
public class ProfileDisplay : Gtk.Box {

  // UI-Elements of ProfileDisplay
  [GtkChild]
  private unowned Gtk.Label profile_display_label;
  [GtkChild]
  private unowned BadgesBox profile_badges;
  [GtkChild]
  private unowned Gtk.Label profile_username_label;
  [GtkChild]
  private unowned Gtk.Label profile_description_label;

  /**
   * The Profile which is displayed.
   */
  public Backend.Profile profile {
    get {
      return displayed_profile;
    }
    set {
      displayed_profile = value;
      // Set's the UI for the new profile
      if (displayed_profile != null) {
        // Set names and description
        profile_display_label.label     = displayed_profile.display_name;
        profile_username_label.label    = @"@$(displayed_profile.username)";
        profile_description_label.label = displayed_profile.description;

        // Set up badges for the profile
        profile_badges.display_verified  = displayed_profile.has_flag (VERIFIED);
        profile_badges.display_bot       = displayed_profile.has_flag (BOT);
        profile_badges.display_protected = displayed_profile.has_flag (PROTECTED);
      }
    }
  }

  /**
   * Stores the displayed profile.
   */
  private Backend.Profile displayed_profile;

}
