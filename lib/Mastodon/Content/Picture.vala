/* Picture.vala
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

public class Backend.Mastodon.Picture : Backend.Picture, Backend.Mastodon.Media  {

  /**
   * Creates an Picture object from a given Json.Object.
   *
   * @param json A Json.Object containing the data.
   */
  public Picture.from_json (Json.Object json) {
    // Set base properties
    base.from_json (json);
  }

  /**
   * Loads the media for display.
   *
   * @return The final media or null if loading failed.
   */
  public async Gdk.Texture? load_media () {
    if (media == null) {
      // Load the image if not in storage
      MediaLoader.load_image.begin (media_url, (obj, res) => {
        media = MediaLoader.load_image.end (res);
      });
      yield;
    }
    // Return stored image
    return media;
  }

  /**
   * The downloaded media in storage.
   */
  private Gdk.Texture? media;

}
