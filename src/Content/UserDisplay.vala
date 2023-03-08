/* UserDisplay.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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
 * Displays an overview over an User.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/UserDisplay.ui")]
public class UserDisplay : Gtk.Widget {

  // General UI-Elements of UserDisplay
  [GtkChild]
  private unowned UserCard user_card;
  [GtkChild]
  private unowned Gtk.Box user_infobox;

  // UI-Elements for text information
  [GtkChild]
  private unowned Gtk.Label user_display_label;
  [GtkChild]
  private unowned BadgesBox user_badges;
  [GtkChild]
  private unowned Gtk.Label user_username_label;
  [GtkChild]
  private unowned Gtk.Label user_description_label;
  [GtkChild]
  private unowned Gtk.Image creation_icon;
  [GtkChild]
  private unowned Gtk.Label creation_label;

  // UI-Elements for metrics
  [GtkChild]
  private unowned Gtk.Label following_counter;
  [GtkChild]
  private unowned Gtk.Label followers_counter;
  [GtkChild]
  private unowned Gtk.FlowBox user_fields;

  /**
   * The User which is displayed.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      // Disconnect prior updaters
      if (update_signal != null) {
        displayed_user.disconnect (update_signal);
      }

      // Set the new value
      displayed_user = value;

      // Connect to the data updater
      if (displayed_user != null) {
        update_signal = displayed_user.user_updated.connect (update_item);
      } else {
        update_signal = null;
      }

      // Fill in the data
      update_item.begin ();
    }
  }

  /**
   * Run at initialization of the class.
   */
  class construct {
    // Set up URL actions
    install_action ("user.open-url", null, (widget, action) => {
      // Get the instance for this
      var display = widget as UserDisplay;

      // Stop if user is null
      if (display.user == null) {
        return;
      }

      // Get the url and opens it
      DisplayUtils.launch_uri (display.user.url, display);
    });
    install_action ("user.copy-url", null, (widget, action) => {
      // Get the instance for this
      var display = widget as UserDisplay;

      // Stop if post is null
      if (display.user == null) {
        return;
      }

      // Get the url and places it in the clipboard
      Gdk.Clipboard clipboard = display.get_clipboard ();
      clipboard.set_text (display.user.url);
    });
  }

  /**
   * Updates the properties for an UserDisplay.
   */
  private async void update_item () {
    // Set names and description
    user_display_label.label       = displayed_user != null ? displayed_user.display_name    : "(null)";
    user_description_label.label   = displayed_user != null ? displayed_user.description     : "(null)";
    user_username_label.label      = displayed_user != null
                                        ? DisplayUtils.prefix_username (displayed_user)
                                        : "(null)";
    user_description_label.visible = user_description_label.label.length > 0;

    // Set up badges for the user
    user_badges.display_verified  = displayed_user != null ? displayed_user.has_flag (VERIFIED)  : false;
    user_badges.display_bot       = displayed_user != null ? displayed_user.has_flag (BOT)       : false;
    user_badges.display_protected = displayed_user != null ? displayed_user.has_flag (PROTECTED) : false;

    // Set the labels for metrics
    following_counter.label = displayed_user != null ? _("<b>%i</b>  Following").printf (displayed_user.following_count) : "(null)";
    followers_counter.label = displayed_user != null ? _("<b>%i</b>  Followers").printf (displayed_user.followers_count) : "(null)";

    // Set the creation field
    creation_icon.tooltip_text = _("Joined %s").printf (displayed_user != null ? displayed_user.domain : "(null)");
    creation_label.label = displayed_user != null ? DisplayUtils.display_time_delta (displayed_user.creation_date, true) : "(null)";

    // Add the data fields by binding the list
    user_fields.bind_model (displayed_user != null ? displayed_user.data_fields : null, (item) => {
      var field     = item as Backend.UserDataField;
      return new UserDataDisplay (field);
    });
  }

  /**
   * Activated when a link in the text is clicked.
   */
  [GtkCallback]
  private bool on_link_clicked (string uri) {
    return DisplayUtils.entities_link_action (uri, this);
  }

  /**
   * Deconstructs UserCard and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplay
    user_card.unparent ();
    user_infobox.unparent ();
    base.dispose ();
  }

  /**
   * Stores the displayed user.
   */
  private Backend.User displayed_user;

  /**
   * Stores the signal handle for updating the data of an user.
   */
  private ulong? update_signal = null;

}
