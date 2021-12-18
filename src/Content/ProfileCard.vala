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
  private unowned CroppedPicture profile_banner;
  [GtkChild]
  private unowned UserAvatar profile_avatar;
  [GtkChild]
  private unowned Adw.Bin card_scrim;
  [GtkChild]
  private unowned Adw.HeaderBar card_header;

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

        // Load and set the Header
        var header = displayed_profile.header.media;
        if (header.is_loaded ()) {
          blurred_banner.paintable = header.get_media ();
          profile_banner.paintable = header.get_media ();
        } else {
          header.begin_loading ();
          header.load_completed.connect (() => {
            blurred_banner.paintable = header.get_media ();
            profile_banner.paintable = header.get_media ();
          });
        }
      }
    }
  }

  /**
   * Set's the widget up on construction.
   */
  construct {
    // Bind the settings to widget properties
    var settings = new Settings ("uk.co.ibboard.Cawbird.experimental");
    settings.bind ("profile-inline-header", card_scrim, "visible",
                    GLib.SettingsBindFlags.DEFAULT);
    settings.bind ("profile-inline-header", card_header, "visible",
                    GLib.SettingsBindFlags.DEFAULT);

    // Installs the header display action
    this.install_action ("profile.display_header", null, (widget, action) => {
      // Get the instance for this
      ProfileCard display = (ProfileCard) widget;

      // Return if no profile is set
      if (display.displayed_profile == null) {
        return;
      }

      // Display the header in a MediaDisplay
      Backend.Media[] media  = { display.displayed_profile.header };
      MainWindow main_window = display.get_root () as MainWindow;
      if (main_window != null) {
        main_window.show_media_display (media);
      } else {
        error ("ProfileCard: Can not display MediaDisplay without MainWindow!");
      }
    });
  }

  /**
   * Stores the displayed profile.
   */
  private Backend.Profile displayed_profile;

}
