/* UserDataDisplay.vala
 *
 * Copyright 2023 Frederick Schenk
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
 * Displays one UserDataField in UserDisplay.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/UserDataDisplay.ui")]
public class UserDataDisplay : Gtk.Widget {

  // UI-Elements of UserDataDisplay
  [GtkChild]
  private unowned Gtk.Image verified_icon;
  [GtkChild]
  private unowned Gtk.Label name_label;
  [GtkChild]
  private unowned Gtk.Label content_label;

  /**
   * The UserDataField to be displayed in this widget.
   */
  public Backend.UserDataField field {
    get {
      return displayed_field;
    }
    construct set {
      displayed_field = value;

      // Update the widget with the new values.
      name_label.label      = displayed_field != null ? displayed_field.name    : "(null)";
      content_label.label   = displayed_field != null ? displayed_field.content : "(null)";

      // Update the verified status
      bool   data_verified    = displayed_field != null ? displayed_field.verified != null : false;
      string verified_tooltip = data_verified
                                     ? _("Verified on %s").printf (DisplayUtils.display_date (displayed_field.verified))
                                     : null;

      verified_icon.visible      = data_verified;
      verified_icon.tooltip_text = verified_tooltip;
      name_label.tooltip_text    = verified_tooltip;
      DisplayUtils.conditional_css (data_verified, this, "verified");
    }
  }

  /**
   * Constructs a new widget for a field.
   *
   * @param field The UserDataField to be displayed in this widget.
   */
  public UserDataDisplay (Backend.UserDataField field) {
    Object (
      field: field,
      css_name: "UserDataDisplay"
    );
  }

  /**
   * Activated when a link in the text is clicked.
   */
  [GtkCallback]
  private bool on_link_clicked (string uri) {
    return DisplayUtils.entities_link_action (uri, this);
  }

  /**
   * Stores the displayed UserDataField.
   */
  private Backend.UserDataField? displayed_field;

}
