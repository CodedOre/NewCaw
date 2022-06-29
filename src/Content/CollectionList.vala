/* CollectionList.vala
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
 * Displays an Collection and allows to filter the resulting list.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/CollectionList.ui")]
public class CollectionList : Gtk.Widget {

  // UI-Elements of CollectionList
  [GtkChild]
  private unowned Gtk.FlowBox filter_box;
  [GtkChild]
  private unowned Gtk.ListBox post_list;

  // Filters for CollectionList
  [GtkChild]
  private unowned FilterButton post_filter;
  [GtkChild]
  private unowned FilterButton repost_filter;
  [GtkChild]
  private unowned FilterButton media_filter;

  /**
   * Which platform the displayed collection is on.
   *
   * Used to determine a few platform-specific strings.
   */
  public PlatformEnum displayed_platform {
    get {
      return set_display_platform;
    }
    set {
      set_display_platform = value;
      switch (set_display_platform) {
        case MASTODON:
          break;

        case TWITTER:
          post_filter.label   = _("Tweets");
          repost_filter.label = _("Retweets");
          break;

        default:
          assert_not_reached();
      }
    }
  }

  /**
   * The Collection being displayed in this list.
   */
  public Backend.Collection collection {
    get {
      return shown_collection;
    }
    set {
      shown_collection = value;
      if (shown_collection != null) {
        // Bind ListModel of Collection to ListBox
        post_list.bind_model (shown_collection.post_list, make_post_widget);

        // Load the posts from the Collection
        shown_collection.pull_posts.begin (() => {
        });
      } else {
        // Unbind possible existing ListModel.
        post_list.bind_model (null, null);
      }
    }
  }

  /**
   * Creates a ListRow for an object from the Collection model.
   *
   * @param object An Object expected to be an Post that can be displayed.
   *
   * @return A Gtk.Widget to be displayed in the list.
   */
  private Gtk.Widget make_post_widget (Object object) {
    // Check we get an Post object
    var post = object as Backend.Post;
    if (post == null) {
      error ("The Collection contained one object not being a Post!");
    }

    // Check if a filter applies to a post
    bool is_repost = post.post_type == REPOST;
    bool has_media = is_repost
                       ? post.referenced_post.get_media ().length > 0
                       : post.get_media ().length > 0;

    // Create ListBoxRow and bind visibilities
    var row = new Gtk.ListBoxRow ();
    if (is_repost) {
      // Bind Reposts filter
      repost_filter.bind_property ("active", row, "visible");
    }
    if (has_media) {
      // Bind Media filter
      media_filter.bind_property ("active", row, "visible");
    }
    if (! is_repost && ! has_media) {
      // Bind all others to Post filter
      post_filter.bind_property ("active", row, "visible");
    }

    // Create PostDisplay
    var display = new PostDisplay (post);

    // Return the new row
    row.child = display;
    return row;
  }

  /**
   * Deconstructs CollectionList and it's childrens.
   */
  public override void dispose () {
    // Destructs children of CollectionList
    filter_box.unparent ();
    post_list.unparent ();
  }

  /**
   * Store the display platform.
   */
  private PlatformEnum set_display_platform;

  /**
   * Stores the displayed Collection.
   */
  private Backend.Collection? shown_collection = null;

}
