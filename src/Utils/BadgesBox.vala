/* BadgesBox.vala
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
 * A small helper widget to display different badges.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Utils/BadgesBox.ui")]
public class BadgesBox : Gtk.Box {

  /**
   * The size for all used icons.
   */
  public int icon_size { get; set; default = 10; }

  /**
   * If the verified badge should be shown.
   */
  public bool display_verified {
    get {
      return verified_visible;
    }
    set {
      verified_visible = value;
      this.visible = verified_visible || bot_visible || protected_visible;
    }
  }

  /**
   * If the bot badge should be shown.
   */
  public bool display_bot {
    get {
      return bot_visible;
    }
    set {
      bot_visible = value;
      this.visible = verified_visible || bot_visible || protected_visible;
    }
  }

  /**
   * If the protected badge should be shown.
   */
  public bool display_protected {
    get {
      return protected_visible;
    }
    set {
      protected_visible = value;
      this.visible = verified_visible || bot_visible || protected_visible;
    }
  }

  /**
   * Stores if the verified badge should be shown.
   */
  private bool verified_visible = false;

  /**
   * Stores if the bot badge should be shown.
   */
  private bool bot_visible = false;

  /**
   * Stores if the protected badge should be shown.
   */
  private bool protected_visible = false;

}
