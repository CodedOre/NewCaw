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

public abstract class Backend.Mastodon.Media : Object, Backend.Media {

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
      case "image":
        return new Picture.from_json (json);
      default:
        error ("Failed to create a Media object: No valid media type!");
    }
  }

  /**
   * The unique identifier for this media.
   */
  public string id { get; }

  /**
   * The url to the preview image for this media.
   */
  public string preview_url { get; }

  /**
   * The url to the full media object.
   */
  public string media_url { get; }

  /**
   * An text description of the media.
   */
  public string alt_text { get; }

  /**
   * Creates an Media object from a given Json.Object.
   *
   * @param json A Json.Object containing the data.
   */
  protected Media.from_json (Json.Object json) {
    // Get basic data
    _id       = json.get_string_member ("id");
    _alt_text = json.get_string_member ("description");

    // Get size data
    Json.Object meta     = json.get_object_member ("meta");
    Json.Object org_meta = meta.get_object_member ("original");
    _width  = (int) org_meta.get_int_member ("width");
    _height = (int) org_meta.get_int_member ("height");

    // Get media urls
    _preview_url = json.get_string_member ("preview_url");
    _media_url   = json.get_string_member ("url");
  }

  /**
   * Loads the preview image for display.
   *
   * @return The final preview image or null if loading failed.
   */
  public async Gdk.Texture? load_preview () {
    // Load from storage if already loaded
    if (preview_image != null) {
      return preview_image;
    }
    // Downloads the preview image
    MemoryInputStream? stream = null;
    NetworkUtils.download_stream.begin (preview_url, null, (obj, res) => {
      stream = NetworkUtils.download_stream.end (res);
    });
    yield;
    if (stream == null) {
      return null;
    }
    // Create a Gdk.Texture using the loaded data
    try {
      var texbuf    = new Gdk.Pixbuf.from_stream (stream);
      preview_image = Gdk.Texture.for_pixbuf (texbuf);
      return preview_image;
    } catch (GLib.Error e) {
      error (@"While creating texture for $(preview_url): $(e.message)");
    }
  }

  /**
   * Returns the size of the widget.
   */
  public void get_dimensions (out int width, out int height) {
    width  = _width;
    height = _height;
  }

  /**
   * The preview image for this media.
   */
  private Gdk.Texture? preview_image;

  /**
   * The width of this media.
   */
  private int _width;

  /**
   * The height of this media.
   */
  private int _height;

}
