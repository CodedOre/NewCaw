/* MediaDialog.vala
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
 * A window containing the MediaDisplay for media.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Media/MediaDialog.ui")]
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
   * Runs at initialization of this class.
   */
  class construct {
    // Set up URL actions
    install_action ("media.copy-url", null, (widget, action) => {
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
    install_action ("media.open-url", null, (widget, action) => {
      // Get the instance for this
      var dialog = widget as MediaDialog;

      // Get the current media
      Backend.Media media = dialog.media_display.visible_media;

      // Get the url and opens it
      DisplayUtils.launch_uri (media.media_url, dialog);
    });
  }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Load the set window size
    var     settings      = new Settings ("uk.co.ibboard.Cawbird.Windows");
    Variant tokens        = settings.get_value ("media-dialog-size");
    int     set_width     = (int) tokens.get_child_value (0).get_int32 ();
    int     set_height    = (int) tokens.get_child_value (1).get_int32 ();

    // Set the default window size
    set_default_size (set_width, set_height);

    // Connect close event
    close_request.connect (on_close);
  }

  /**
   * Run when MediaDialog is closed.
   */
  private bool on_close () {
    // Store the current window size as setting
    var set_width  = new Variant.int32 (get_size (HORIZONTAL));
    var set_height = new Variant.int32 (get_size (VERTICAL));
    var set_size   = new Variant.tuple ({set_width, set_height});
    var settings   = new Settings ("uk.co.ibboard.Cawbird.Windows");
    settings.set_value ("media-dialog-size", set_size);

    // Close the window for good
    destroy ();
    return true;
  }

}
