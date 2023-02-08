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

      // Set's the UI for the new user
      // FIXME: We need to clear (or update) the flowbox on updates
      if (displayed_user != null) {
        // Create a special creation date field
        var creation_field         = new Gtk.Box (HORIZONTAL, 4);
        var creation_icon          = new Gtk.Image.from_icon_name ("x-office-calendar-symbolic");
        creation_icon.tooltip_text = _("Joined %s").printf (displayed_user.domain);
        var creation_value         = new Gtk.Label (DisplayUtils.display_time_delta (
                                                      displayed_user.creation_date, true));
        creation_field.append (creation_icon);
        creation_field.append (creation_value);
        user_fields.insert (creation_field, -1);

        // Set up the fields for the user
        foreach (Backend.UserDataField field in displayed_user.get_data_fields ()) {
          var field_box = new Gtk.Box (HORIZONTAL, 4);

          // Create labels for name and content
          var field_name    = new Gtk.Label (field.name);
          var field_content = new Gtk.Label (field.content);
          field_name.add_css_class ("heading");
          field_content.use_markup = true;

          // Add the widgets to the user_fields box
          field_box.append (field_name);
          field_box.append (field_content);
          user_fields.insert (field_box, -1);
        }
      }
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
      Gtk.show_uri (null, display.user.url, Gdk.CURRENT_TIME);
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
