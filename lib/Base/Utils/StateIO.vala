/* WindowManagement.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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

namespace Backend.Utils.StateIO {
  /**
   * Loads a GVariant from the state file.
   *
   * @param state_path The path to store the state in
   * @param file_name The file name to store
   *
   * @return The GVariant from the file, or null if not existing.
   *
   * @throws Error Errors while accessing the state file.
   */
   public Variant? load_file (string state_path, string file_name) throws Error {
    // Initialize the file
    var file = File.new_build_filename (state_path, file_name, null);

    Variant? stored_state;
    try {
      // Load the data from the file
      uint8[] file_content;
      string file_etag;
      file.load_contents (null, out file_content, out file_etag);
      // Convert the file data to an Variant and read the values from it
      var stored_bytes = new Bytes.take (file_content);
      stored_state = new Variant.from_bytes (new VariantType ("a{sv}"), stored_bytes, false);
    } catch (Error e) {
      // Don't put warning out if the file can't be found (expected error)
      if (! (e is IOError.NOT_FOUND)) {
        throw e;
      }
      stored_state = null;
    }
    return stored_state;
  }

  /**
   * Stores a GVariant to the state file.
   *
   *
   * @param state_path The path to store the state in
   * @param file_name The file name to store
   * @param variant The GVariant to be stored.
   *
   * @throws Error Errors while accessing the state file.
   */
  public void store_file (string state_path, string file_name, Variant variant) throws Error {
    // Initialize the file
    var file = File.new_build_filename (state_path, file_name, null);

    // Convert the variant to Bytes and store to file
    try {
      Bytes bytes = variant.get_data_as_bytes ();
      file.replace_contents (bytes.get_data (), null,
                             false, REPLACE_DESTINATION,
                             null, null);
    } catch (Error e) {
      throw e;
    }
  }
}
