/* UserDisplay.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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
      displayed_user = value;
      // Set's the UI for the new user
      if (displayed_user != null) {
        // Set names and description
        user_display_label.label     = displayed_user.display_name;
        user_username_label.label    = @"@$(displayed_user.username)";
        user_description_label.label = displayed_user.description;

        // Set up badges for the user
        user_badges.display_verified  = displayed_user.has_flag (VERIFIED);
        user_badges.display_bot       = displayed_user.has_flag (BOT);
        user_badges.display_protected = displayed_user.has_flag (PROTECTED);

        // Set the labels for metrics
        following_counter.label = _("<b>%i</b>  Following").printf (displayed_user.following_count);
        followers_counter.label = _("<b>%i</b>  Followers").printf (displayed_user.followers_count);

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
          var field_box   = new Gtk.Box (HORIZONTAL, 4);

          // Create either an icon or an label for the field name
          Gtk.Widget field_desc;
          switch (field.type) {
            case WEBLINK:
              field_desc              = new Gtk.Image.from_icon_name ("web-browser-symbolic");
              field_desc.tooltip_text = _("Website");
              break;
            case LOCATION:
              field_desc              = new Gtk.Image.from_icon_name ("mark-location-symbolic");
              field_desc.tooltip_text = _("Location");
              break;
            default:
              field_desc = new Gtk.Label (field.name);
              field_desc.add_css_class ("heading");
              break;
          }

          // Create an label for the field value, optional with activatable link
          string display_label;
          if (field.target != null) {
            // Escape the text not intended to be Pango markup
            string target  = Markup.escape_text (field.target);
            string tooltip = Markup.escape_text (target);
            string display = Markup.escape_text (field.display);
            // Create a link should target have a value
            display_label = @"<a href=\"$(target)\" title=\"$(tooltip)\" class=\"weblink\">$(display)</a>";
          } else {
            display_label = field.display;
          }
          var field_value        = new Gtk.Label (display_label);
          field_value.use_markup = true;

          // Add the widgets to the user_fields box
          field_box.append (field_desc);
          field_box.append (field_value);
          user_fields.insert (field_box, -1);
        }
      }
    }
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

}
