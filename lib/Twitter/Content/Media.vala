/* Media.vala
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

public abstract class Backend.Twitter.Media : Object, Backend.Media {

  /**
   * Creates the right sub-class of Media for a given Json.Object.
   *
   * @param json A Json.Object containing the media.
   *
   * @return A sub-class of Backend.Media suitable for the contained media.
   */
  public static Backend.Media create_media_from_json (Json.Object json) {
    string media_type = json.get_string_member ("type");
    switch (media_type) {
      case "photo":
        return new Picture.from_json (json);
      default:
        error ("Failed to create a Media object: Unknown media type!");
    }
  }

  /**
   * The unique identifier for this media.
   */
  public string id { get; construct; }

  /**
   * An text description of the media.
   */
  public string alt_text { get; construct; }

  /**
   * The ImageLoader to load the preview.
   */
  public ImageLoader preview { get; construct; }

  /**
   * The original width of this media.
   */
  public int width { get; construct; }

  /**
   * The original height of this media.
   */
  public int height { get; construct; }

}
