/* MediaDialog.vala
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
 * A window containing the MediaDisplay for media.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Windows/MediaDialog.ui")]
public class MediaDialog : Adw.Window {

  // UI-Elements of MediaDialog
  [GtkChild]
  private unowned Adw.ToastOverlay toasts;
  [GtkChild]
  private unowned MediaDisplay media_display;

  /**
   * Creates a new MediaDialog to display some media.
   *
   * @param widget The widget calling the constructor, used to determine the parent window.
   * @param media An array of Media objects to be displayed.
   * @param focus Which of the media objects should be initially focused.
   */
  public MediaDialog (Gtk.Widget widget, Backend.Media[] media, int focus = 0) {
    // Get the parent window of the widget
    Gtk.Root widget_root   = widget.get_root ();
    var      parent_window = widget_root as Gtk.Window;

    // Set the new media on the display widget
    media_display.set_media (media, focus);

    // Connect the new dialog to the parent window
    if (parent_window != null) {
      this.set_transient_for (parent_window);
    }

    // Show the dialog
    this.present ();
  }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Set up URL actions
    this.install_action ("media.copy-url", null, (widget, action) => {
      // Get the instance for this
      var dialog = widget as MediaDialog;

      // Get the current media
      Backend.Media media = dialog.media_display.visible_media;

      // Get the url and places it in the clipboard
      Gdk.Clipboard clipboard = dialog.get_clipboard ();
      clipboard.set_text (media.media_url);

      // Notify the user about the copied url
      dialog.toasts.add_toast (new Adw.Toast (_("URL to media copied!")));
    });
    this.install_action ("media.open-url", null, (widget, action) => {
      // Get the instance for this
      var dialog = widget as MediaDialog;

      // Get the current media
      Backend.Media media = dialog.media_display.visible_media;

      // Get the url and opens it
      Gtk.show_uri (null, media.media_url, Gdk.CURRENT_TIME);
    });
  }

}
