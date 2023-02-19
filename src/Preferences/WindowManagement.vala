/* WindowManagement.vala
 *
 * Copyright 2023 IBBoard
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

namespace Preferences.WindowManagement {
    public void store_state(string state_path, List<WindowAllocation?> window_allocations) throws Error {
        // Prepare to build the state variant
        var state_builder = new VariantBuilder (new VariantType ("a{sv}"));

        // Pack each server into the state variant
        var window_builder = new VariantBuilder (new VariantType ("av"));
        foreach (WindowAllocation window_allocation in window_allocations) {
          window_builder.add ("v", pack_window (window_allocation));
        }
        state_builder.add ("{sv}", "Windows", window_builder.end ());

        // Store the state variant in a file
        Backend.Utils.StateIO.store_file (state_path, "windows.gvariant", state_builder.end ());
    }

    private Variant pack_window (WindowAllocation window_allocation) throws Error {
      // Create the VariantBuilder and check the platform
      var state_builder = new VariantBuilder (new VariantType ("a{smv}"));

      // Add the data to the variant
      state_builder.add ("{smv}", "account_id", new Variant.string(window_allocation.session_id));
      state_builder.add ("{smv}", "window_allocation", new Variant("(ii)", window_allocation.width, window_allocation.height));

      // Return the created variant
      return state_builder.end ();
    }

    private async List<WindowAllocation?> load_state(string state_path) throws Error {
        Variant? window_states_variant = Backend.Utils.StateIO.load_file(state_path, "windows.gvariant");
        List<WindowAllocation?> window_allocations = new List<WindowAllocation?>();

        if (window_states_variant == null) {
            return window_allocations;
        }

        // Load the server data
        Variant stored_windows = window_states_variant.lookup_value ("Windows", null);
        VariantIter window_iter = stored_windows.iterator ();
        Variant window_variant;
        while (window_iter.next ("v", out window_variant)) {
          var window = unpack_window (window_variant);
          if (window.width != 0 && window.height != 0 && window.session_id != null) {
            window_allocations.append (window);
          }
        }

        return window_allocations;
    }

    private WindowAllocation unpack_window(Variant variant) {
        WindowAllocation window_allocation = {0, 0, ""};
        Variant geometry_variant, account_id_variant;

        variant.lookup ("account_id", "mv", out account_id_variant);
        window_allocation.session_id = account_id_variant.get_string();
        variant.lookup ("window_allocation", "mv", out geometry_variant);
        if (geometry_variant != null && geometry_variant.n_children() == 2) {
            int w = 0, h = 0;
            geometry_variant.get("(ii)", &w, &h);
            window_allocation.width = w;
            window_allocation.height = h;
        }

        return window_allocation;
    }
}