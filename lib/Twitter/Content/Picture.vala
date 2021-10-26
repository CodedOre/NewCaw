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
  public ImageLoader media { get; }

  /**
   * Creates an Picture object from a given Json.Object.
   *
   * @param json A Json.Object containing the data.
   */
  public Picture.from_json (Json.Object json) {
    // Set urls for preview and media
    string base_url = json.get_string_member ("url");
    preview_url     = @"$(base_url)?name=small";
    media_url       = @"$(base_url)?name=large";

    // Create a ImageLoader for the media
    _media   = new ImageLoader (media_url);

    // Set base properties
    base.from_json (json);
  }

}
