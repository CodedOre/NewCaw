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
   * The ImageLoader to load the media.
   */
  public ImageLoader media { get; construct; }

  /**
   * Creates an Picture object from a specific url.
   *
   * @param media_url The url to the full media.
   * @param preview_url The url to the preview image, if available.
   */
  public Picture (string media_url, string? preview_url = null) {
    // Constructs an Object from the json
    Object (
      // Don't set basic information
      id:       null,
      alt_text: null,
      width:    -1,
      height:   -1,

      // Create MediaLoaders from urls
      preview: preview_url != null ? new ImageLoader (preview_url) : null,
      media:   new ImageLoader (media_url)
    );
  }

  /**
   * Creates an Picture object from a given Json.Object.
   *
   * @param json A Json.Object containing the data.
   */
  public Picture.from_json (Json.Object json) {
    // Get size data
    Json.Object meta     = json.get_object_member ("meta");
    Json.Object org_meta = meta.get_object_member ("original");

    // Constructs an Object from the json
    Object (
      // Set basic information
      id:       json.get_string_member ("id"),
      alt_text: json.get_string_member ("description"),
      width:    (int) org_meta.get_int_member ("width"),
      height:   (int) org_meta.get_int_member ("height"),

      // Create MediaLoaders from urls
      preview:  new ImageLoader (json.get_string_member ("preview_url")),
      media:    new ImageLoader (json.get_string_member ("url"))
    );
  }

}
