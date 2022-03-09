/* MainWindow.vala
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

/**
 * The main window of the application, also responsible for new windows.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/MainWindow.ui")]
public class MainWindow : Adw.ApplicationWindow {

  // UI-Elements of MainWindow
  [GtkChild]
  private unowned Adw.Leaflet leaflet;

  /**
   * Initializes a MainWindow.
   */
  public MainWindow (Gtk.Application app) {
    // Initializes the Object
    Object (application: app);

#if DEBUG
    // Add development style in debug
    this.add_css_class ("devel");
#endif
  }

  /**
   * Displays a MediaDisplay as an sub-window.
   *
   * @param media The media to be displayed in the new display.
   * @param focus The index of the media which should get the focus.
   */
  public void show_media_display (Backend.Media[] media, int focus = 0) {
    // Create a MediaDisplay for the media
    var display = new MediaDisplay (media, focus);

    // Create a window holding the MediaDisplay
    var display_window   = new Adw.Window ();
    display_window.modal = true;

    // Place the MediaDisplay in the window and presents it
    display_window.set_content (display);
    display_window.set_transient_for (this);
    display_window.present ();
  }

}
