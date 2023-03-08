/* AppearancesPage.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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
 * Displays the page regarding the appearance options.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Preferences/AppearancesPage.ui")]
public class Preferences.AppearancesPage : Adw.PreferencesPage {

  // UI-Elements of AppearancesPage
  [GtkChild]
  private unowned PostItem example_post_item;
  [GtkChild]
  private unowned Gtk.Switch round_avatar_switch;
  [GtkChild]
  private unowned Gtk.Switch trailing_tags_switch;
  [GtkChild]
  private unowned Gtk.Switch double_click_activation_switch;

  /**
   * Run at construction of the page.
   */
  construct {
    // Bind the settings to the preferences widget
    var settings = new Settings ("uk.co.ibboard.Cawbird");
    settings.bind ("round-avatars",
                   round_avatar_switch, "active",
                   GLib.SettingsBindFlags.DEFAULT);
    settings.bind ("trailing-tags",
                   trailing_tags_switch, "active",
                   GLib.SettingsBindFlags.DEFAULT);
    settings.bind ("double-click-activation",
                   double_click_activation_switch, "active",
                   GLib.SettingsBindFlags.DEFAULT);

    // Set up the example post
    example_post_item.post = new Backend.Utils.ExamplePost ();
  }

}
