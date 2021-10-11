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
 * A helper class providing static methods to load media.
 */
internal class Backend.MediaLoader : Object {

  /**
   * Loads an image from a url and returns it as a Gdk.Texture.
   *
   * @param url The url from which the image is loaded.
   *
   * @return A Gdk.Texture containing the image, or null if failed.
   */
  public static async Gdk.Texture? load_image (string url) {
    // Initialize loader and result
    MediaLoader self   = get_loader ();
    Gdk.Texture result;

    // Initiate the task
    // FIXME: Other type than null for no callback?
    var load_task = new Task (self, null, null);

    load_task.set_task_data (url, null);

    // Load and convert the image in a thread.
    try {
      // Run the loader in a thread
      load_task.run_in_thread_sync (load_image_threaded);
      // Get the output and set's it as the result
      Value thread_result;
      load_task.propagate_value (out thread_result);
      result = thread_result.get_object () as Gdk.Texture;
    } catch (Error e) {
      error (@"Failed to download media from link \"@(url)\": $(e.message)");
    }

    return result;
  }

  /**
   * Loads an image inside a thread.
   *
   * Implements the delegate GLib.TaskThreadFunc.
   *
   * @param task The task which is running this thread.
   * @param self The MediaLoader initiating this call.
   * @param data Data given to the function (in this case the url).
   * @param cancellable The cancellable to cancel this thread.
   */
  private static void load_image_threaded (Task task, Object self, void* data, Cancellable? cancellable) {
    // Initialize session, stream and url
    string             url          = (string) data;
    var                load_session = new Soup.Session ();
    MemoryInputStream? stream       = null;

    // Load the media as a input stream
    stream = download_stream (url, load_session, null);

    // Fail when stream is empty
    if (stream == null) {
      // FIXME: Replace this with an return_error
      task.return_value (null);
      return;
    }

    // Create a Gdk.Texture with the stream
    // TODO: Replace the Pixbuf creation with Bytes when this is available (GTK 4.6)
    try {
      var texbuf  = new Gdk.Pixbuf.from_stream (stream);
      var texture = Gdk.Texture.for_pixbuf (texbuf);
      task.return_value (texture);
    } catch (Error e) {
      task.return_error (e);
    }
  }

  /**
   * Loads an GLib.MemoryInputStream from a given url.
   *
   * @param url The url with the content.
   * @param session The Soup.Session to use.
   * @param cancellable A GLib.Cancellable
   *
   * @return The content loaded in an GLib.MemoryInputStream, or null if failed.
   */
  private static MemoryInputStream? download_stream (string url, Soup.Session session, Cancellable? cancellable) {
    // Init call
    Bytes              streambytes;
    MemoryInputStream? result      = null;
    var                message     = new Soup.Message ("GET", url);

    // Load the data
    try {
      streambytes = session.send_and_read (message, cancellable);
      result      = new MemoryInputStream.from_bytes (streambytes);
    } catch (Error e) {
      error (@"While downloading $(url): $(e.message)");
    }

    // Return the loaded data
    return result;
  }

  /**
   * Returns or creates the global MediaLoader.
   *
   * @return A unowned instance of the MediaLoader.
   */
  private static unowned MediaLoader get_loader () {
    if (global_loader == null) {
      // Creates a MediaLoader if needed
      global_loader = new MediaLoader ();
    }
    // Returns the global instance
    return global_loader;
  }

  /**
   * The global session of the MediaLoader.
   */
  private static MediaLoader? global_loader;

}
