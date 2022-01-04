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
public class Backend.TwitterLegacy.Media : Backend.Media {

  /**
   * The unique identifier for this media.
   */
  public string id { get; construct; }

  /**
   * The type for this media.
   */
  public MediaType type { get; construct; }

  /**
   * An text description of the media.
   */
  public string alt_text { get; construct; }

  /**
   * Retrieves the preview as a Gdk.Paintable.
   *
   * Loads the preview from the web asynchronously and
   * returns the Gdk.Paintable when it is loaded.
   *
   * @return A Gdk.Paintable with the preview.
   */
  public async Gdk.Paintable get_preview () {
  }

  /**
   * Retrieves the preview as a Gdk.Paintable.
   *
   * Loads the preview from the web asynchronously and
   * returns the Gdk.Paintable when it is loaded.
   *
   * @return A Gdk.Paintable with the preview.
   */
  public async Gdk.Paintable get_media () {
  }

}
