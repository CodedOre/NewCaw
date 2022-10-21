/* ClientState.vala
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

/**
 * Stores all active sessions and servers, and allows
 * saving and loading client states from disk.
 */
[SingleInstance]
internal class Backend.ClientState : Object {

  /**
   * The global instance of ClientState.
   */
  private static ClientState instance {
    get {
      if (global_instance == null) {
        global_instance = new ClientState ();
      }
      return global_instance;
    }
  }

  /**
   * Stores the global instance of ClientState.
   */
  private static ClientState? global_instance = null;

}
