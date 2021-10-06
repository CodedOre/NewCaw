/* NetworkUtils.vala
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

namespace Backend.NetworkUtils {

  /**
   * Loads an GLib.MemoryInputStream from a given url.
   *
   * @param url The url with the content.
   * @param cancellable A GLib.Cancellable
   *
   * @return The content loaded in an GLib.MemoryInputStream, or null if failed.
   */
  private async MemoryInputStream? download_stream (string url, Cancellable? cancellable = null) {
    // Init call
    MemoryInputStream result   = null;
    var               message  = new Soup.Message ("GET", url);

    // Load the data asynchronous
    global_session ().send_and_read_async.begin (
      message, Priority.DEFAULT, cancellable, (obj, res) => {
        if (cancellable.is_cancelled ()) {
          return;
        }
        try {
          Bytes streambytes = global_session ().send_and_read_async.end (res);
          result = new MemoryInputStream.from_bytes (streambytes);
        } catch (GLib.Error e) {
          error (@"While downloading $(url): $(e.message)");
        }
      }
    );

    // Return the loaded data
    return result;
  }

  /**
   * Returns the global Soup.Session and creates it if needed.
   *
   * @return The global Soup.Session.
   */
  private static Soup.Session global_session () {
    if (_global_session == null) {
      _global_session = new Soup.Session ();
    }
    return _global_session;
  }

  /**
   * The global Soup.Session storage.
   *
   * Only access over get_session()!
   */
  private static Soup.Session? _global_session = null;

}
