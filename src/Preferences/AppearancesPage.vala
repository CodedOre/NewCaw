/* AppearancesPage.vala
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
    display_example_post ();
  }

  /**
   * Displays a example post in the page.
   */
  private void display_example_post () {
    // Define the path to the example json
    string? resource_id;
#if SUPPORT_MASTODON
    resource_id = "resource:///uk/co/ibboard/Cawbird/ui/Preferences/Examples/ExampleMastodonPost.json";
#else
    warning ("No example JSON available for the page!");
    example_post_item.post = null;
    return;
#endif

    // Loads the json for the example post
    try {
      Backend.Post example_post;
      // Load the resource as file
      var   file     = File.new_for_uri (resource_id);
      Bytes resource = file.load_bytes ();
      var   stream   = new MemoryInputStream.from_bytes (resource);

      // Parse the resource to the json objects
      var json_parser = new Json.Parser ();
      json_parser.load_from_stream (stream);
#if SUPPORT_MASTODON
      Json.Object post_data = json_parser.get_root ().get_object ();
      // example_post = Backend.Mastodon.Post.from_json (post_data);
#endif

      // Set the example post
      example_post_item.post = null;
    } catch (Error e) {
      warning (@"Failed to set the example post: $(e.message)");
      example_post_item.post = null;
    }
  }

}
