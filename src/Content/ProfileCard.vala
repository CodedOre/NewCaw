/* ProfileCard.vala
 *
 * Copyright 2021 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Displays a Profiles banner, avatar and names.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/ProfileCard.ui")]
public class ProfileCard : Gtk.Widget {

  // UI-Elements of ProfileCard
  [GtkChild]
  private unowned CroppedPicture blurred_banner;
  [GtkChild]
  private unowned Adw.Clamp banner_clamp;
  [GtkChild]
  private unowned CroppedPicture profile_banner;
  [GtkChild]
  private unowned UserAvatar profile_avatar;
  [GtkChild]
  private unowned Gtk.WindowHandle card_header;
  [GtkChild]
  private unowned Adw.Clamp content_clamp;

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
        // Set the profile images
        profile_avatar.set_avatar (displayed_profile.avatar);
      }
    }
  }

  /**
   * Bind settings to this widget on construction.
   */
  construct {
    var settings = new Settings ("uk.co.ibboard.Cawbird.experimental");
    settings.bind ("profile-inline-header", card_header, "visible",
                    GLib.SettingsBindFlags.DEFAULT);
  }

  /**
   * Stores the displayed profile.
   */
  private Backend.Profile displayed_profile;

}
