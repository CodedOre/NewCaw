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
[SingleInstance]
internal class Backend.MediaLoader : Object {

  /**
   * An instance for the MediaLoader.
   */
  internal static MediaLoader instance {
    get {
      if (global_instance == null) {
        global_instance = new MediaLoader ();
      }
      return global_instance;
    }
  }

  /**
   * Run at construction of the class.
   */
  construct {
    // Initialize session
    soup_session = new Soup.Session ();
    // Create cache dir if not already existing
    var cache_dir = Path.build_filename (Environment.get_user_cache_dir (),
                                         Client.instance.name,
                                         null);
    DirUtils.create_with_parents (cache_dir, 0750);
  }

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

    // Check for cached version of the media
    uint media_hash  = url.hash ();
    var  media_cache = File.new_build_filename (Environment.get_user_cache_dir (),
                                                Client.instance.name,
                                                media_hash.to_string (),
                                                null);

    // Create loading message
    var message = new Soup.Message ("GET", url);

    // Load media from url
    try {
      stream = yield instance.soup_session.send_async (message, 0, null);
    } catch (Error e) {
      throw e;
    }

    // Cache the loaded media
    var cache_stream = media_cache.replace (null, false, FileCreateFlags.NONE);
    cache_stream.splice (stream, CLOSE_TARGET);

    // Create the paintable according to media_type
    try {
      switch (media_type) {
        case PICTURE:
          paintable  = Gdk.Texture.from_file (media_cache);
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
   * The global instance of MediaLoader.
   */
  private static MediaLoader? global_instance = null;

  /**
   * The Soup.Session handling the loading of the media.
   */
  internal Soup.Session soup_session;

}
