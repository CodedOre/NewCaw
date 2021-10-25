/* MediaLoader.vala
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
 * An interface containing basic utilities for downloading media.
 */
public abstract class Backend.MediaLoader : Object {

  /**
   * Signals that the download is completed.
   */
  public signal void load_completed ();

  /**
   * Creates an MediaLoader and prepares it for loading the image.
   *
   * @param url The url of the image to be loaded.
   */
  internal MediaLoader (string url) {
    // Set the to be loaded url.
    loaded_url = url;
  }

  /**
   * Initiates the download.
   */
  public abstract void begin_loading ();

  /**
   * Returns the download progress.
   *
   * @return A double representing the progress of the load.
   */
  public double load_progress () {
    return 0.0;
  }

  /**
   * Loads an GLib.MemoryInputStream from a given url.
   *
   * @param url The url with the content.
   * @param session The Soup.Session to use.
   * @param cancellable A GLib.Cancellable.
   *
   * @throws GLib.Error Errors that resulted while Soup downloaded the stream.
   *
   * @return The content loaded in an GLib.MemoryInputStream, or null if failed.
   */
  private MemoryInputStream? download_stream (string       url,
                                              Soup.Session session,
                                              Cancellable? cancellable)
                                              throws Error
  {
    // Init call
    Bytes             streambytes;
    MemoryInputStream result;
    var               message = new Soup.Message ("GET", url);

    // Load the data
    try {
      streambytes = session.send_and_read (message, cancellable);
      result      = new MemoryInputStream.from_bytes (streambytes);
    } catch (Error e) {
      throw e;
    }

    // Return the loaded data
    return result;
  }

  /**
   * The url for the media to be downloaded.
   */
  protected string loaded_url;

}
