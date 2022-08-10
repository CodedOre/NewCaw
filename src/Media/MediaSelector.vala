/* MediaSelector.vala
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
 * A widget previewing a media and allowing to select it.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Media/MediaSelector.ui")]
public class MediaSelector : Gtk.Button {

  // UI-Elements of MediaSelector
  [GtkChild]
  private unowned Gtk.Spinner load_indicator;
  [GtkChild]
  private unowned CroppedPicture media_holder;
  [GtkChild]
  private unowned Gtk.Box media_indicator_box;
  [GtkChild]
  private unowned Gtk.Image animated_type_indicator;
  [GtkChild]
  private unowned Gtk.Image video_type_indicator;
  [GtkChild]
  private unowned Gtk.Image alt_text_indicator;

  /**
   * The media to be displayed in this selector.
   */
  public Backend.Media media {
    get {
      return displayed_media;
    }
    set {
      displayed_media = value;

      // Create a new Cancellable and remove possible old ones
      if (load_cancellable != null) {
        load_cancellable.cancel ();
        load_cancellable = null;
      }
      load_cancellable = new Cancellable ();

      // Set the media indicators
      animated_type_indicator.visible = displayed_media != null ? displayed_media.media_type == ANIMATED : false;
      video_type_indicator.visible    = displayed_media != null ? displayed_media.media_type == VIDEO    : false;
      alt_text_indicator.visible      = displayed_media != null ? displayed_media.alt_text != null       : false;
      alt_text_indicator.tooltip_text = displayed_media != null ? displayed_media.alt_text               : null;

      // Make media_indicator_box visible when a indicator is set
      media_indicator_box.visible = animated_type_indicator.visible || video_type_indicator.visible || alt_text_indicator.visible;

      // Don't allow the button to be pressed without media
      this.sensitive = displayed_media != null;

      // Clear media holder and only load media if there is some
      media_holder.paintable = null;
      if (displayed_media == null) {
        load_indicator.spinning = false;
        return;
      }

      // Activate the load indicator
      load_indicator.spinning = true;

      // Load the preview image
      displayed_media.get_preview.begin (load_cancellable, (obj, res) => {
        try {
          var paintable = displayed_media.get_preview.end (res) as Gdk.Paintable;
          if (media_holder.paintable == null) {
            media_holder.paintable = paintable;
          }
        } catch (Error e) {
          warning (@"Could not load media preview: $(e.message)");
        } finally {
          load_indicator.spinning = false;
        }
      });

      // Load the full media if property is set
      if (! only_preview) {
        displayed_media.get_media.begin (load_cancellable, (obj, res) => {
          try {
            var paintable = displayed_media.get_media.end (res) as Gdk.Paintable;
            media_holder.paintable = paintable;
          } catch (Error e) {
            warning (@"Could not load media: $(e.message)");
          } finally {
            load_indicator.spinning = false;
          }
        });
      }
    }
  }

  /**
   * If only the preview should be loaded.
   */
  public bool only_preview { get; set; default = true; }

  /**
   * Deconstructs MediaSelector and it's childrens
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
    // Destructs children of MediaSelector
    base.dispose ();
  }

  /**
   * A GLib.Cancellable to cancel loads when removing the widget.
   */
  private Cancellable? load_cancellable = null;

  /**
   * Stores the displayed media.
   */
  private Backend.Media? displayed_media = null;

}
