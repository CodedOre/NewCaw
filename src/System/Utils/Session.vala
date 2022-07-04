/* Session.vala
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
 * Loads and stores persistent states about accounts, servers and windows.
 */
[SingleInstance]
public class Session : Object {

  /**
   * The instance of this session.
   */
  public static Session instance {
    get {
      if (global_instance == null) {
        critical ("Session needs to be initialized before using it!");
      }
      return global_instance;
    }
  }

  /**
   * The application the session runs in.
   */
  public Gtk.Application application { get; construct; }

  /**
   * Runs at construction of the instance.
   */
  construct {
  }

  /**
   * Creates a new instance of the session.
   *
   * @param application The Application this session runs in.
   */
  private Session (Gtk.Application application) {
    Object (
      application: application
    );
  }

  /**
   * Initializes the session.
   *
   * @param application The Application this session runs in.
   */
  public static void init (Gtk.Application application) {
    global_instance = new Session (application);
  }

  /**
   * Stores the global instance of this session.
   */
  private static Session? global_instance = null;

}
