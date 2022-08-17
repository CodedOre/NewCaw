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
 * Displays an Collection with an header and filter options.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/CollectionView.ui")]
public class CollectionView : Gtk.Widget {

  // UI-Elements of CollectionView
  [GtkChild]
  private unowned Gtk.ScrolledWindow scroll_window;
  [GtkChild]
  private unowned Gtk.ListView listview;

  /**
   * The default headers needed in a collection for CollectionList.
   *
   * In order for CollectionList to properly display the header and filters,
   * append this constant when creating a instance of an Collection.
   */
  public const string[] HEADERS = { "header", "separator", "filters" };

  /**
   * A header widget to be displayed on top of the collection.
   */
  public Gtk.Widget header { get; set; }

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
      filter_options.displayed_platform = set_display_platform;
    }
  }

  /**
   * The collection which is to be displayed.
   */
  public Backend.Collection collection {
    get {
      return shown_collection;
    }
    set {
      shown_collection = value;

      if (shown_collection != null) {
        // Bind the collection to the list
        var filter_list = new Gtk.FilterListModel (shown_collection.post_list, list_filter);
        var list_model = new Gtk.NoSelection (filter_list);
        listview.set_model (list_model);
      } else {
         listview.set_model (null);
      }

      // Pull the posts from the list
      shown_collection.pull_posts.begin ();
    }
  }

  /**
   * Run at construction of an widget.
   */
  construct {
    // Initialize additional widgets
    list_separator = new Gtk.Separator (HORIZONTAL);
    filter_options = new CollectionFilter ();
    list_separator.margin_bottom = 32;

    // Create a list filter from the collection
    list_filter = new Gtk.CustomFilter (filter_items);
    filter_options.filters_changed.connect (() => {
      list_filter.changed (DIFFERENT);
    });

    // Create the ListFactory and bind the signals
    var list_factory = new Gtk.SignalListItemFactory ();
    listview.factory = list_factory;
    list_factory.setup.connect (on_setup);
    list_factory.bind.connect (on_bind);
    list_factory.unbind.connect (on_unbind);
    list_factory.teardown.connect (on_teardown);
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
      warning ("Unsupported widget returned by ListView!");
      return;
    }
    // Create an empty PostItem and set it as child
    var post_item = new PostItem ();
    item.set_child (post_item);
  }

  /**
   * Run when a widget is set to display a specific item.
   *
   * @param object The object returned by the ListFactory.
   */
  private void on_bind (Object object) {
    // Cast the object to a Gtk.ListItem
    var item = object as Gtk.ListItem;
    if (item == null) {
      warning ("Unsupported widget returned by ListView!");
      return;
    }
    // Check the type of object to be displayed
    Object data = item.item;
    if (data is Backend.PseudoItem) {
      bind_header (item, data as Backend.PseudoItem);
    } else if (data is Backend.Post) {
      bind_post (item, data as Backend.Post);
    } else {
      warning ("Unsupported object to be displayed by ListView!");
    }
  }

  /**
   * Binds an header widget to an item.
   *
   * @param item The ListItem returned by the ListFactory.
   * @param data The PseudoItem returned by the ListFactory.
   */
  private void bind_header (Gtk.ListItem item, Backend.PseudoItem data) {
    // Remove existing child widget
    Gtk.Widget? widget = item.child;
    if (widget != null) {
      widget.unparent ();
    }

    // Select the right widget to show
    Gtk.Widget? new_widget;
    switch (data.description) {
      case "header":
        new_widget = header;
        break;

      case "separator":
        new_widget = list_separator;
        break;

      case "filters":
        new_widget = filter_options;
        break;

      default:
        new_widget = null;
        break;
    }

    // Display the right widget
    item.child = new_widget;
  }

  /**
   * Binds an post to an item.
   *
   * @param item The ListItem returned by the ListFactory.
   * @param post The Post returned by the ListFactory.
   */
  private void bind_post (Gtk.ListItem item, Backend.Post post) {
    // Check that an PostItem is available
    if (! (item.child is PostItem)) {
      item.child = new PostItem ();
    }

    // Display the post
    var post_item = item.child as PostItem;
    if (post_item != null) {
      post_item.post = post;
    }
  }

  /**
   * Run when a widget has its displayed item unset.
   *
   * @param object The object returned by the ListFactory.
   */
  private void on_unbind (Object object) {
    // Cast the object to a Gtk.ListItem
    var item = object as Gtk.ListItem;
    if (item == null) {
      warning ("Unsupported widget returned by ListView!");
      return;
    }

    // Remove post from PostItems
    var post_item = item.child as PostItem;
    if (post_item != null) {
      post_item.post = null;
    }
  }

  /**
   * Run when a widget is removed from memory.
   *
   * @param object The object returned by the ListFactory.
   */
  private void on_teardown (Object object) {
    // Cast the object to a Gtk.ListItem
    var item = object as Gtk.ListItem;
    if (item == null) {
      warning ("Unsupported widget returned by ListView!");
      return;
    }

    // Unparent if not header items
    Gtk.Widget? widget = item.child;
    if (widget == header || widget == list_separator || widget == filter_options) {
      item.child = null;
    } else if (widget != null) {
      widget.unparent ();
    }
  }

  /**
   * Determines if an item should be displayed.
   *
   * @param item The item to check.
   *
   * @return If the item should be displayed.
   */
  private bool filter_items (Object item) {
    // Check if the item is a post
    var post = item as Backend.Post;
    if (post == null) {
      // If not, display it always
      return true;
    }

    // Determine the type of the post
    bool is_repost = post.post_type == REPOST;
    bool has_media = is_repost
                       ? post.referenced_post.get_media ().length > 0
                       : post.get_media ().length > 0;

    // Check the type against the filters
    if (is_repost) {
      return filter_options.display_reposts;
    }
    if (has_media) {
      return filter_options.display_media;
    }
    return filter_options.display_generic;
  }

  /**
   * Deconstructs CollectionView and it's childrens.
   */
  public override void dispose () {
    // Destructs children of CollectionView
    scroll_window.unparent ();
    base.dispose ();
  }

  /**
   * Store the display platform.
   */
  private PlatformEnum set_display_platform;

  /**
   * The Gtk.Filter used to filter the posts.
   */
  private Gtk.Filter list_filter;

  /**
   * A Gtk.Separator separating header and list.
   */
  private Gtk.Separator list_separator;

  /**
   * The CollectionFilter widget to filter the list.
   */
  private CollectionFilter filter_options;

  /**
   * Stores the displayed Collection.
   */
  private Backend.Collection? shown_collection = null;

}
