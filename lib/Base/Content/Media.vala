/* Media.vala
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
 * Stores an media for loading and display.
 */
public abstract class Backend.Media : Object {

  /**
   * The unique identifier for this media.
   */
  public string id { get; construct; }

  /**
   * The type for this media.
   */
  public MediaType media_type { get; construct; }

  /**
   * An text description of the media.
   */
  public string alt_text { get; construct; }

  /**
   * The url leading to the preview.
   */
  public string preview_url { get; construct; }

  /**
   * The url leading to the media.
   */
  public string media_url { get; construct; }

  /**
   * Emitted when get_preview finishes loading the preview.
   */
  private signal void preview_loaded ();

  /**
   * Emitted when get_media finishes loading the media.
   */
  private signal void media_loaded ();

  /**
   * Retrieves the preview as a Gdk.Paintable.
   *
   * Loads the preview from the web asynchronously and
   * returns the Gdk.Paintable when it is loaded.
   *
   * @param cancellable A GLib.Cancellable to cancel the load.
   *
   * @return A Gdk.Paintable with the preview.
   *
   * @throws Error Any error that happens on loading.
   */
  public async Gdk.Paintable? get_preview (Cancellable? cancellable = null) throws Error {
    // Return null if no preview_url is set
    if (preview_url == null) {
      return null;
    }

    // Return the fully loaded preview
    if (preview != null) {
      return preview;
    }

    if (! preview_loading) {
      // If no call loads the preview, lock it and start loading
      try {
        preview_loading = true;
        preview = yield MediaLoader.load_media (PICTURE, preview_url, cancellable);
      } catch (Error e) {
        throw e;
      } finally {
        preview_loading = false;
        preview_loaded ();
      }
    } else {
      // If another call loads the preview, wait until the preview_loaded signal is emitted.
      SourceFunc callback = get_preview.callback;
      preview_loaded.connect (() => {
        Idle.add ((owned) callback);
      });
      yield;
    }

    // Return the loaded preview
    return preview;
  }

  /**
   * Retrieves the media as a Gdk.Paintable.
   *
   * Loads the media from the web asynchronously and
   * returns the Gdk.Paintable when it is loaded.
   *
   * @param cancellable A GLib.Cancellable to cancel the load.
   *
   * @return A Gdk.Paintable with the media.
   *
   * @throws Error Any error that happens on loading.
   */
  public async Gdk.Paintable? get_media (Cancellable? cancellable = null) throws Error  {
    // Return null if no media_url is set
    if (media_url == null) {
      return null;
    }

    // Return the fully loaded media
    if (media != null) {
      return media;
    }

    if (! media_loading) {
      // If no call loads the media, lock it and start loading
      try {
        media_loading = true;
        media = yield MediaLoader.load_media (media_type, media_url, cancellable);
      } catch (Error e) {
        throw e;
      } finally {
        media_loading = false;
        media_loaded ();
      }
    } else {
      // If another call loads the media, wait until the media_loaded signal is emitted.
      SourceFunc callback = get_media.callback;
      media_loaded.connect (() => {
        Idle.add ((owned) callback);
      });
      yield;
    }

    // Return the loaded media
    return media;
  }

  /**
   * The stored preview paintable.
   */
  private Gdk.Paintable? preview = null;

  /**
   * If an process is loading the preview.
   */
  private bool preview_loading = false;

  /**
   * The stored media paintable.
   */
  private Gdk.Paintable? media = null;

  /**
   * If an process is loading the media.
   */
  private bool media_loading = false;

}
