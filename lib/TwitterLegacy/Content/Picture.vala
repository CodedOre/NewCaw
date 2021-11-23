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

public class Backend.TwitterLegacy.Picture : Backend.Picture, Backend.TwitterLegacy.Media  {

  /**
   * The ImageLoader to load the media.
   */
  public ImageLoader media { get; construct; }

  /**
   * Creates an Picture object from a given Json.Object.
   *
   * @param json A Json.Object containing the data.
   */
  public Picture.from_json (Json.Object json) {
    // Get base url for preview and media
    string base_url = json.get_string_member ("media_url_https");

    // Get size object for media
    Json.Object sizes_obj = json.get_object_member ("sizes");
    Json.Object large_obj = sizes_obj.get_object_member ("large");

    // Constructs an Object from the json
    Object (
      // Set basic information
      id:       json.get_string_member ("id_str"),
      alt_text: json.has_member ("ext_alt_text") ? json.get_string_member ("ext_alt_text") : "",
      width:    (int) large_obj.get_int_member ("w"),
      height:   (int) large_obj.get_int_member ("h"),

      // Create MediaLoaders from base_url
      preview:  new ImageLoader (@"$(base_url)?name=small"),
      media:    new ImageLoader (@"$(base_url)?name=large")
    );
  }

}
