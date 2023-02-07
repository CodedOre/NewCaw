/* CollectionFilter.vala
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
 * Provides the user the FilterButtons to filter posts.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/CollectionFilter.ui")]
public class CollectionFilter : Gtk.Widget {

  // UI-Elements of CollectionFilter
  [GtkChild]
  private unowned Gtk.FlowBox filter_box;
  [GtkChild]
  private unowned FilterButton generic_filter;
  [GtkChild]
  private unowned FilterButton replies_filter;
  [GtkChild]
  private unowned FilterButton reposts_filter;
  [GtkChild]
  private unowned FilterButton media_filter;

  /**
   * Which platform the displayed collection is on.
   *
   * Used to determine a few platform-specific strings.
   */
  public Backend.PlatformEnum displayed_platform {
    get {
      return set_display_platform;
    }
    set {
      set_display_platform = value;
      switch (set_display_platform) {
        default:
          generic_filter.label = _("Posts");
          reposts_filter.label = _("Reposts");
          break;
      }
    }
  }

  /**
   * If generic posts should be displayed.
   */
  public bool display_generic { get; set; }

  /**
   * If replies should be displayed.
   */
  public bool display_replies { get; set; }

  /**
   * If reposts should be displayed.
   */
  public bool display_reposts { get; set; }

  /**
   * If media posts should be displayed.
   */
  public bool display_media { get; set; }

  /**
   * Deconstructs CollectionFilter and it's childrens.
   */
  public override void dispose () {
    // Destructs children of CollectionFilter
    filter_box.unparent ();
    base.dispose ();
  }

  /**
   * Store the display platform.
   */
  private Backend.PlatformEnum set_display_platform;

}
