/* TextModule.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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
 * The type of content a TextModules stores.
 *
 * Used when formatting the text for the UI.
 */
public enum Backend.TextModuleType {
  TEXT,
  TAG,
  TRAIL_TAG,
  MENTION,
  WEBLINK
}

/**
 * Stores a part of an text in a Post.
 *
 * A text in an Post is internally split into multiple TextModules
 * which store parts of different type, as seen in TextModuleType.
 */
public struct Backend.TextModule {

  /**
   * What content this module stores.
   */
  public TextModuleType type;

  /**
   * The text contained in this module.
   */
  public string display;

  /**
   * The target link of the module, used as tooltip and link.
   */
  public string? target;

  /**
   * The start position in the text.
   */
  public uint text_start;

  /**
   * The end position in the text.
   */
  public uint text_end;

}
