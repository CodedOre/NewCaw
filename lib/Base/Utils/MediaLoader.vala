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
 * An helper class holding code for loading media from a server.
 */
internal class Backend.MediaLoader : Object {

  /**
   * Load a media asynchronously.
   *
   * @param media_type The type to be loaded.
   * @param url The url to load from.
   *
   * @return A Gdk.Paintable for the media, or null if failed.
   */
  internal static async Gdk.Paintable? load_media (MediaType media_type, string url) {
    return null;
  }

}
