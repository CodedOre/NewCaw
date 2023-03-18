/* CollectionList.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Collections/CollectionView.ui")]
public class CollectionView : Gtk.Widget {

  // UI-Elements of CollectionView
  [GtkChild]
  private unowned Gtk.ScrolledWindow scroll_window;
  [GtkChild]
  private unowned Gtk.ListView listview;

  // Elements that may appear in the list
  [GtkChild]
  private unowned CollectionFilter filter_options;
  [GtkChild]
  private unowned Gtk.Separator list_separator;
  [GtkChild]
  private unowned Adw.ActionRow timeout_indicator;

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
   * The id for a post which is displayed as the "main post".
   */
  public string? main_post_id { get; set; default = null; }

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

      // Unbind the filter bindings
      unbind(ref display_generic_binding);
      unbind(ref display_reposts_binding);
      unbind(ref display_replies_binding);
      unbind(ref display_media_binding);

      if (shown_collection != null) {
        // Bind the collection to the list
        list_model = new Gtk.NoSelection (shown_collection);
        listview.set_model (list_model);

        // Pull the posts from the list
        var pullable = shown_collection as Backend.PullableCollection;
        if (pullable != null) {
          pullable.pull_items.begin ();
        }

        // Enable the filters
        var post_filters = shown_collection as Backend.PostFilters;
        filter_options.visible = post_filters != null;
        if (post_filters != null) {
          filter_options.display_generic = post_filters.display_generic;
          filter_options.display_reposts = post_filters.display_reposts;
          filter_options.display_replies = post_filters.display_replies;
          filter_options.display_media   = post_filters.display_media;
          post_filters.bind_property ("display_generic", filter_options, "display_generic", BIDIRECTIONAL);
          post_filters.bind_property ("display_reposts", filter_options, "display_reposts", BIDIRECTIONAL);
          post_filters.bind_property ("display_replies", filter_options, "display_replies", BIDIRECTIONAL);
          post_filters.bind_property ("display_media",   filter_options, "display_media", BIDIRECTIONAL);
        }
      } else {
        list_model = null;
        listview.set_model (null);
      }
    }
  }

  /**
   * Run at construction of an widget.
   */
  construct {
    // Create the ListFactory and bind the signals
    var list_factory = new Gtk.SignalListItemFactory ();
    listview.factory = list_factory;
    list_factory.setup.connect (on_setup);
    list_factory.bind.connect (on_bind);
    list_factory.unbind.connect (on_unbind);
    list_factory.teardown.connect (on_teardown);

    // Bind the double-click setting
    var settings = new Settings ("uk.co.ibboard.Cawbird");
    settings.bind ("double-click-activation",
                   listview, "single-click-activate",
                   GLib.SettingsBindFlags.INVERT_BOOLEAN);
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
    if (data is Backend.HeaderItem) {
      bind_header (item, data as Backend.HeaderItem);
    } else if (data is Backend.Post) {
      bind_post (item, data as Backend.Post);
    } else {
      warning ("Unsupported object to be displayed by ListView!");
    }

    // Only make posts selectable
    item.activatable = data is Backend.Post;
    item.selectable  = data is Backend.Post;
  }

  /**
   * Binds an header widget to an item.
   *
   * @param item The ListItem returned by the ListFactory.
   * @param data The HeaderItem returned by the ListFactory.
   */
  private void bind_header (Gtk.ListItem item, Backend.HeaderItem data) {
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

      case "timeout":
        new_widget = timeout_indicator;
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

    var post_item = item.child as PostItem;
    if (post_item != null) {
      // Set the display mode
      post_item.display_mode = main_post_id == post.id
                                 ? PostItem.DisplayMode.MAIN
                                 : PostItem.DisplayMode.LIST;

      // Check pinned items
      if (shown_collection is Backend.CollectionPins) {
        var pin_collection = shown_collection as Backend.CollectionPins;
        post_item.pinned_item = pin_collection.is_pinned_post (post);
      }

      // Set the connecting lines
      if (shown_collection is Backend.PostConnections) {
        var connect = shown_collection as Backend.PostConnections;
        post_item.connect_to_previous = post.replied_to_id != main_post_id
                                          ? connect.connected_to_previous (post)
                                          : false;
        post_item.connect_to_next     = connect.connected_to_next (post);
      } else {
        post_item.connect_to_previous = false;
        post_item.connect_to_next     = false;
      }

      // Display the post
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

    // Unbind header widgets from the listview
    if (item.child == header || item.child == list_separator || item.child == filter_options || item.child == timeout_indicator) {
      item.child = null;
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
   * Runs when a row was activated.
   *
   * @param index The index of the activated row.
   */
  [GtkCallback]
  private void on_activation (uint index) {
    // Only run if a list is present
    if (list_model == null) {
      return;
    }

    // Get the activated object
    var object = list_model.get_object (index);

    // Run actions when object is a post.
    var post = object as Backend.Post;
    if (post != null) {
      // Get the MainWindow
      var main_window = this.get_root () as MainWindow;
      if (main_window == null) {
        warning ("CollectionView not in a MainWindow, action not possible!");
        return;
      }

      // Display the post in a thread
      main_window.display_thread (post);
    }
  }

  private void unbind (ref GLib.Binding? binding) {
    if (binding != null) {
      binding.unbind();
      binding = null;
    }
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
  private Backend.PlatformEnum set_display_platform;

  /**
   * Stores the displayed Collection.
   */
  private Backend.Collection? shown_collection = null;

  /**
   * Stores the currently used Gtk.SelectionModel.
   */
  private Gtk.SelectionModel? list_model = null;

  // Used to bind filters for collection and UI
  private GLib.Binding? display_generic_binding;
  private GLib.Binding? display_reposts_binding;
  private GLib.Binding? display_replies_binding;
  private GLib.Binding? display_media_binding;

}
