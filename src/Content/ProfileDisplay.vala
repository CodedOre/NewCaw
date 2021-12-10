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
public class ProfileDisplay : Gtk.Widget {

  // General UI-Elements of ProfileDisplay
  [GtkChild]
  private unowned ProfileCard profile_card;
  [GtkChild]
  private unowned Adw.Clamp content_clamp;

  // UI-Elements for text information
  [GtkChild]
  private unowned Gtk.Label profile_display_label;
  [GtkChild]
  private unowned BadgesBox profile_badges;
  [GtkChild]
  private unowned Gtk.Label profile_username_label;
  [GtkChild]
  private unowned Gtk.Label profile_description_label;

  // UI-Elements for metrics
  [GtkChild]
  private unowned Gtk.Label following_counter;
  [GtkChild]
  private unowned Gtk.Label followers_counter;
  [GtkChild]
  private unowned Gtk.Box profile_fields;

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

        // Set the labels for metrics
        following_counter.label = _("<b>%i</b>  Following").printf (displayed_profile.following_count);
        followers_counter.label = _("<b>%i</b>  Followers").printf (displayed_profile.followers_count);

        // Create a special creation date field
        var creation_field         = new Gtk.Box (HORIZONTAL, 4);
        var creation_icon          = new Gtk.Image.from_icon_name ("x-office-calendar-symbolic");
        creation_icon.tooltip_text = _("Joined %s").printf (displayed_profile.domain);
        var creation_value         = new Gtk.Label (DisplayUtils.display_time_delta (
                                                      displayed_profile.creation_date, true));
        creation_field.append (creation_icon);
        creation_field.append (creation_value);
        profile_fields.append (creation_field);

        // Set up the fields for the profile
        foreach (Backend.UserDataField field in displayed_profile.get_data_fields ()) {
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
          var field_value        = new Gtk.Label (field.value);
          field_value.use_markup = true;

          // Add the widgets to the profile_fields box
          field_box.append (field_desc);
          field_box.append (field_value);
          profile_fields.append (field_box);
        }
      }
    }
  }

  /**
   * Deconstructs ProfileCard and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplay
    profile_card.unparent ();
    content_clamp.unparent ();
  }

  /**
   * Stores the displayed profile.
   */
  private Backend.Profile displayed_profile;

}
