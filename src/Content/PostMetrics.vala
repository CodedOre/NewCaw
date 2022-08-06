/* PostMetrics.vala
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
 * Displays metrics about an post without any interactivity.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/PostMetrics.ui")]
public class PostMetrics : Gtk.Widget {

  // UI-Elements of PostMetrics
  [GtkChild]
  private unowned Gtk.Box likes_box;
  [GtkChild]
  private unowned Gtk.Box repost_box;
  [GtkChild]
  private unowned Gtk.Box replies_box;
  [GtkChild]
  private unowned Gtk.Label likes_counter;
  [GtkChild]
  private unowned Gtk.Label repost_counter;
  [GtkChild]
  private unowned Gtk.Label replies_counter;

  /**
   * The post which metrics are displayed in this widget.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      displayed_post = value;

      // Set the information on the UI
      likes_counter.label   = displayed_post != null ? displayed_post.liked_count.to_string ("%'d")    : "(null)";
      repost_counter.label  = displayed_post != null ? displayed_post.reposted_count.to_string ("%'d") : "(null)";
      replies_counter.label = displayed_post != null ? displayed_post.replied_count.to_string ("%'d")  : "(null)";
    }
  }

  /**
   * Deconstructs PostItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of PostItem
    likes_box.unparent ();
    repost_box.unparent ();
    replies_box.unparent ();
  }

  /**
   * Stores the displayed repost.
   */
  private Backend.Post? displayed_post = null;

}
