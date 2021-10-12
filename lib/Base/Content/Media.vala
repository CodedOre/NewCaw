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

/**
 * A generic interface for media from a platform.
 *
 * This contains shared properties and
 * methods for the specialized media classes.
 */
public interface Backend.Media : Object {

  /**
   * The unique identifier for this media.
   */
  public abstract string id { get; }

  /**
   * The url to the preview image for this media.
   */
  public abstract string preview_url { get; protected set; }

  /**
   * The url to the full media object.
   */
  public abstract string media_url { get; protected set; }

  /**
   * An text description of the media.
   */
  public abstract string alt_text { get; }

  /**
   * Notices the frontend of a completed download.
   */
  public signal void load_preview_completed ();

  /**
   * Loads the preview image for display.
   */
  public abstract async Gdk.Texture? load_preview ();

  /**
   * Returns the size of the widget.
   */
  public abstract void get_dimensions (out int width, out int height);

}
