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
  private unowned Gtk.ListView post_list;

  // Filters for CollectionList
  [GtkChild]
  private unowned FilterButton generic_filter;
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
          generic_filter.label = _("Tweets");
          repost_filter.label  = _("Retweets");
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
        // Bind the collection to the list
        var filter_list = new Gtk.FilterListModel (shown_collection.post_list, post_filter);
        var list_model = new Gtk.NoSelection (filter_list);
        post_list.set_model (list_model);
      } else {
         post_list.set_model (null);
      }

      // Pull the posts from the list
      shown_collection.pull_posts.begin ();
    }
  }

  /**
   * Run at construction of an widget.
   */
  construct {
    // Create a filter list from the collection
    post_filter = new Gtk.CustomFilter (filter_posts);

    // Create the ListFactory and bind the signals
    var list_factory  = new Gtk.SignalListItemFactory ();
    post_list.factory = list_factory;
    list_factory.setup.connect (on_setup);
    list_factory.bind.connect (on_bind);
    list_factory.unbind.connect (on_unbind);
  }

  /**
   * Run when a FilterButton was changed.
   */
  [GtkCallback]
  private void on_filter_changed () {
    post_filter.changed (DIFFERENT);
  }

  /**
   * Run when a new widget in the list is created.
   *
   * @param object The new object returned by the ListFactory.
   */
  private void on_setup (Object object) {
    // Cast the object to a Gtk.ListItem
    var item = object as Gtk.ListItem;
    if (item == null) {
      warning ("Unknown widget returned by ListView!");
      return;
    }
    // Create an empty PostItem and set it as child
    var post_item = new PostItem ();
    item.set_child (post_item);
  }

  /**
   * Run when a widget is set to display a specific post.
   *
   * @param object The object returned by the ListFactory.
   */
  private void on_bind (Object object) {
    // Cast the object to a Gtk.ListItem
    var item = object as Gtk.ListItem;
    if (item == null) {
      warning ("Unknown widget returned by ListView!");
      return;
    }
    // Get the widget and post
    var widget = item.child as PostItem;
    var post   = item.item  as Backend.Post;
    // Assign the post to the item
    if (widget != null) {
      widget.post = post;
    }
  }

  /**
   * Run when a widget has its displayed post unset.
   *
   * @param object The object returned by the ListFactory.
   */
  private void on_unbind (Object object) {
    // Cast the object to a Gtk.ListItem
    var item = object as Gtk.ListItem;
    if (item == null) {
      warning ("Unknown widget returned by ListView!");
      return;
    }
    // Get the widget and unset the post
    var widget = item.child as PostItem;
    widget.post = null;
  }

  /**
   * Determines if an object should be displayed.
   *
   * @param object The object to check.
   *
   * @return If the post should be displayed.
   */
  private bool filter_posts (Object object) {
    // Cast the object to a post and return false if failing
    var post = object as Backend.Post;
    if (post == null) {
      return false;
    }

    // Determine the type of the post
    bool is_repost = post.post_type == REPOST;
    bool has_media = is_repost
                       ? post.referenced_post.get_media ().length > 0
                       : post.get_media ().length > 0;

    // Check the type against the filters
    if (is_repost) {
      return repost_filter.active;
    }
    if (has_media) {
      return media_filter.active;
    }
    return generic_filter.active;
  }

  /**
   * Deconstructs CollectionList and it's childrens.
   */
  public override void dispose () {
    // Destructs children of CollectionList
    filter_box.unparent ();
    post_list.unparent ();
    base.dispose ();
  }

  /**
   * Store the display platform.
   */
  private PlatformEnum set_display_platform;

  /**
   * The Gtk.Filter used to filter the posts.
   */
  private Gtk.Filter post_filter;

  /**
   * Stores the displayed Collection.
   */
  private Backend.Collection? shown_collection = null;

}
