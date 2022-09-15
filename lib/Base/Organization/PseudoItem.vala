/* PseudoItem.vala
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
 * A pseudo item added to an Collection to indicate to
 * a ListView it needs to use a special widget.
 *
 * Only added by a Collection subclass as a header item.
 */
public class Backend.PseudoItem : Object {

  /**
   * An index used while sorting the collection to order multiple PseudoItems.
   */
  public int index { get; construct; }

  /**
   * An description for the UI to place the right widget.
   */
  public string description { get; construct; }

  /**
   * Creates an instance of this object.
   *
   * @param index An index used while sorting the collection to order multiple PseudoItems.
   * @param description An description for the UI to place the right widget.
   */
  internal PseudoItem (int index, string description) {
    Object (
      index: index,
      description: description
    );
  }

}
