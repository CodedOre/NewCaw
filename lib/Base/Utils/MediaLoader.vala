/* MediaLoader.vala
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
 * Error domain for errors in MediaLoader.
 */
errordomain MediaLoaderError {
  INVALID_CONVERT
}

/**
 * An helper class holding code for loading media from a server.
 */
internal class Backend.MediaLoader : Object {

  /**
   * Load a media asynchronously.
   *
   * @param media_type The type to be loaded.
   * @param url The url to load from.
   *
   * @return A Gdk.Paintable for the media.
   *
   * @throws Error Any error that occurs while loading or converting.
   */
  internal static async Gdk.Paintable load_media (MediaType media_type,
                                                     string url,
                                               Cancellable? cancellable = null
  ) throws Error {
    // Init function
    InputStream   stream;
    Gdk.Paintable paintable;

    // Create loading message
    var message = new Soup.Message ("GET", url);

    // Load media from url
    try {
      stream = yield soup_session.send_async (message, 0, null);
    } catch (Error e) {
      throw e;
    }

    // Create the paintable according to media_type
    try {
      switch (media_type) {
        case PICTURE:
          var pixbuf = new Gdk.Pixbuf.from_stream (stream);
          paintable  = Gdk.Texture.for_pixbuf (pixbuf);
          break;
        default:
          throw new MediaLoaderError.INVALID_CONVERT ("Could not create paintable");
      }
    } catch (Error e) {
      throw e;
    }

    // Return the result
    return paintable;
  }

  /**
   * A global Soup.Session for loading.
   */
  internal static Soup.Session soup_session {
    get {
      if (soup_session_store == null) {
        soup_session_store = new Soup.Session ();
      }
      return soup_session_store;
    }
  }

  /**
   * Stores the global Soup.Session.
   *
   * Only to be loaded from the property!
   */
  private static Soup.Session? soup_session_store = null;

}
