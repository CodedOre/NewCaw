/* PostItem.vala
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
 * Displays one post.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/PostItem.ui")]
public class PostItem : Gtk.Widget {

  /**
   * How the content will be displayed.
   */
  public enum DisplayMode {
    /**
     * Will be normally displayed, designed for use in a list.
     */
    LIST,
    /**
     * Text selectable and additional information, designed for selected posts.
     */
    MAIN,
    /**
     * Smaller display, used for quoted posts.
     */
    QUOTE
  }

  // UI-Elements of PostItem
  [GtkChild]
  private unowned Gtk.Box pinned_status;
  [GtkChild]
  private unowned Gtk.Label pinned_label;
  [GtkChild]
  private unowned PostStatus repost_status;
  [GtkChild]
  private unowned PostStatus post_status;
  [GtkChild]
  private unowned Gtk.Box content_box;
  [GtkChild]
  private unowned Adw.Bin next_line_bin;
  [GtkChild]
  private unowned Gtk.Label info_label;
  [GtkChild]
  private unowned PostContent post_content;

  /**
   * How this PostDisply will display it's content.
   */
  public DisplayMode display_mode {
    get {
      return set_display_mode;
    }
    construct set {
      set_display_mode = value;

      info_label.visible         = set_display_mode == MAIN;
      post_status.show_time      = set_display_mode != MAIN;
      post_status.display_inline = set_display_mode == QUOTE;
      next_line_bin.visible      = ! (set_display_mode != LIST);
      content_box.margin_top     = set_display_mode != LIST ? 8 : 0;
    }
  }

  /**
   * The post displayed in this widget.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      // Disconnect prior updaters
      if (update_signal != null) {
        displayed_post.disconnect (update_signal);
      }

      // Set the new value
      displayed_post = value;

      // Connect to the data updater
      if (displayed_post != null) {
        update_signal = displayed_post.post_updated.connect (update_item);
      } else {
        update_signal = null;
      }

      // Fill in the data
      update_item ();
    }
  }

  /**
   * If the PostItem is marked as pinned on a UserPage.
   */
  public bool pinned_item { get; set; }

  /**
   * If a line to the previous PostItem should be drawn.
   */
  public bool connect_to_previous { get; set; }

  /**
   * If a line to the next PostItem should be drawn.
   */
  public bool connect_to_next { get; set; }

  /**
   * Creates a new PostItem with an specific display_mode.
   *
   * @param mode The display mode for this PostDisplay.
   */
  public PostItem (DisplayMode mode = LIST) {
    Object (
      display_mode: mode
    );
  }

  /**
   * Run at initialization of the class.
   */
  class construct {
    // Set up URL actions
    install_action ("post.copy-url", null, (widget, action) => {
      // Get the instance for this
      var item = widget as PostItem;

      // Stop if post is null
      if (item.post == null) {
        return;
      }

      // Get the url and places it in the clipboard
      Gdk.Clipboard clipboard = item.get_clipboard ();
      clipboard.set_text (item.main_post.url);
    });
    install_action ("post.open-url", null, (widget, action) => {
      // Get the instance for this
      var item = widget as PostItem;

      // Stop if post is null
      if (item.post == null) {
        return;
      }

      // Get the url and opens it
      DisplayUtils.launch_uri (item.main_post.url, item);
    });
    // Set up "display media" action
    install_action ("post.display_media", "i", (widget, action, arg) => {
      // Get the instance for this
      var item = widget as PostItem;

      // Return if post is null
      if (item.post == null) {
        return;
      }

      // Get the parameters
      int             focus = (int) arg.get_int32 ();
      Backend.Media[] media = item.main_post.get_media ();

      // Display the media in an MediaDialog
      new MediaDialog (item, media, focus);
    });
  }

  /**
   * Updates the properties for an PostItem.
   */
  private void update_item () {
    bool has_repost;
    Backend.Post? repost = null;

    // Check if we have a repost
    has_repost = displayed_post != null && displayed_post.post_type == REPOST;
    repost = has_repost ? displayed_post : null;
    main_post = has_repost ? displayed_post.referenced_post : displayed_post;

    // Set up pin information
    pinned_label.label = pinned_item && main_post != null
                           ? _("Pinned by %s").printf (main_post.author.display_name)
                           : "";

    // Set the PostStatus widgets
    repost_status.visible     = has_repost;
    repost_status.post        = repost;
    post_status.post          = main_post;
    post_status.show_previous = has_repost || connect_to_previous;

    // Set the main post information
    string post_date   = main_post != null ? main_post.creation_date.format ("%x, %X") : "(null)";
    string post_source = main_post != null ? main_post.source : "(null)";
    info_label.label   = _("%s using %s").printf (post_date, post_source);

    // Set the content widget
    post_content.post = main_post;
  }

  /**
   * Deconstructs PostItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of PostItem
    pinned_status.unparent ();
    repost_status.unparent ();
    post_status.unparent ();
    content_box.unparent ();
    base.dispose ();
  }

  /**
   * Stores the set display mode.
   */
  private DisplayMode set_display_mode = LIST;

  /**
   * Stores the displayed repost.
   */
  private Backend.Post? displayed_post = null;

  /**
   * Stores the signal handle for updating the data of an post.
   */
  private ulong? update_signal = null;

  /**
   * Stores the post in the main view.
   */
  private Backend.Post? main_post = null;

}
