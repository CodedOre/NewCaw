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

  /**
   * Creates a new ProfileDisplay widget displaying a specific Profile.
   *
   * @param profile The Profile which is to be displayed in this widget.
   */
  public ProfileDisplay (Backend.Profile profile) {
  }

}
