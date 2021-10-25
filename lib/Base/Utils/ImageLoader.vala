/* ImageLoader.vala
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
 * A MediaLoader for downloading images.
 */
public class Backend.ImageLoader : Backend.MediaLoader {

  /**
   * Creates an ImageLoader and prepares it for loading the image.
   *
   * @param url The url of the image to be loaded.
   */
  internal ImageLoader (string url) {
    base (url);
  }

  /**
   * Initiates the download.
   */
  public override void begin_loading () {
    // Creates a Task for loading
    var load_task = new Task (this, null, finalize_loading);
    load_task.set_task_data (loaded_url, null);

    // Runs the loading in a thread
    load_task.run_in_thread (load_threaded);
  }

  /**
   * Returns the final downloaded media.
   *
   * @return The final media for download, or null if not possible.
   */
  public Gdk.Texture? get_media () {
    return image;
  }

  /**
   * Loads the image in a thread and converts it for usage.
   *
   * Implements the delegate GLib.TaskThreadFunc.
   *
   * @param task The task which is running this thread.
   * @param self The ImageLoader initiating this call.
   * @param data Data given to the function (in this case the url).
   * @param cancellable The cancellable to cancel this thread.
   */
  private static void load_threaded (Task         task,
                                     Object       self,
                                     void*        data,
                                     Cancellable? cancellable) {
    // Initialize session, stream and url
    string            url          = (string) data;
    var               load_session = new Soup.Session ();
    MemoryInputStream stream;

    // Load the media as a input stream
    try {
      stream = download_stream (url, load_session, null);
    } catch (Error e) {
      task.return_error (e);
      return;
    }

    // Create a Gdk.Texture with the stream
    // TODO: (Maybe) replace the Pixbuf creation with Bytes when this is available (GTK 4.6)
    try {
      var texbuf  = new Gdk.Pixbuf.from_stream (stream);
      var texture = Gdk.Texture.for_pixbuf (texbuf);
      task.return_value (texture);
    } catch (Error e) {
      task.return_error (e);
    }
  }

  /**
   * Stores the downloaded image and notifies the callers.
   *
   * Implements delegate GLib.TaskReadyCallback.
   *
   * @param self The ImageLoader initiating this call.
   * @param task The task which is running this thread.
   */
  private void finalize_loading  (Object? self, Task task) {
    try {
      // Retrieve and store the image
      Value thread_result;
      task.propagate_value (out thread_result);
      image = thread_result.get_object () as Gdk.Texture;
    } catch (Error e) {
      // Display any error that could have happened
      warning (@"Failed to download media from link \"@(url)\": $(e.message)");
    }

    // Notifies callers
    load_completed ();
  }

  /**
   * The loaded image.
   */
  private Gdk.Texture? image = null;

}
