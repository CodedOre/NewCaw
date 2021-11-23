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

public class Backend.Twitter.Picture : Backend.Picture, Backend.Twitter.Media  {

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
    string base_url = json.get_string_member ("url");

    // Constructs an Object from the json
    Object (
      // Set basic information
      id:       json.get_string_member ("media_key"),
      alt_text: json.has_member ("alt_text") ? json.get_string_member ("alt_text") : null,
      width:    (int) json.get_int_member ("width"),
      height:   (int) json.get_int_member ("height"),

      // Create MediaLoaders from base_url
      preview:  new ImageLoader (@"$(base_url)?name=small"),
      media:    new ImageLoader (@"$(base_url)?name=large")
    );
  }

}
