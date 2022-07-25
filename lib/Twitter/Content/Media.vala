/* Media.vala
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
 * Stores an media for loading and display.
 */
public class Backend.Twitter.Media : Backend.Media {

  /**
   * Creates a Media object from a specific url.
   *
   * @param type The type for the media
   * @param media_url The url to the full media.
   * @param preview_url The url to the preview image, if available.
   */
  public Media (MediaType type, string media_url, string? preview_url = null) {
    // Constructs the object
    Object (
      // Don't set id and alt_text
      id:       null,
      alt_text: null,

      // Set the type
      media_type: type,

      // Create MediaLoaders from urls
      preview_url: preview_url,
      media_url:   media_url
    );
  }

  /**
   * Creates a Media object from a given Json.Object.
   *
   * @param json A Json.Object containing the data.
   */
  public Media.from_json (Json.Object json) {
    // Determine the type of this media
    string    type_string = json.get_string_member ("type");
    MediaType type_enum;
    switch (type_string) {
      case "photo":
        type_enum = PICTURE;
        break;
      case "animated_gif":
        type_enum = ANIMATED;
        break;
      case "video":
        type_enum = VIDEO;
        break;
      default:
        warning ("Failed to create a Media object: Unknown media type!");
        return;
    }

    string? preview_url = null, media_url = null;

    // Get the url for images
    if (type_enum == PICTURE) {
      string base_url = json.get_string_member ("url");
      preview_url = @"$(base_url)?name=small";
      media_url   = @"$(base_url)?name=large";
    }

    // Get the url to the video if animated or video
    if (type_enum == ANIMATED || type_enum == VIDEO) {
      // Iterate trough all variants to retrieve the best one
      string     best_variant = null;
      int64      best_bitrate = -1;
      Json.Array media_variants = json.get_array_member ("variants");
      media_variants.foreach_element ((array, index, element) => {
        if (element.get_node_type () == OBJECT) {
          Json.Object obj = element.get_object ();
          int64 bitrate   = obj.has_member ("bit_rate") ? obj.get_int_member ("bit_rate") : 0;
          if (bitrate > best_bitrate) {
            best_bitrate = bitrate;
            best_variant = obj.get_string_member ("url");
          }
        }
      });
      // Store the new urls
      preview_url = json.get_string_member ("preview_image_url");
      media_url   = best_variant;
    }

    // Constructs an Object from the json
    Object (
      // Set basic information
      id:         json.get_string_member ("media_key"),
      media_type: type_enum,
      alt_text:   json.has_member ("alt_text") ? json.get_string_member ("alt_text") : null,

      // Create MediaLoaders from base_url
      preview_url: preview_url,
      media_url:   media_url
    );
  }

}
