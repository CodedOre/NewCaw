/* PostItem.vala
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
 * Displays the content of one Post.
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
  private unowned Gtk.Label text_label;
  [GtkChild]
  private unowned MediaPreview media_previewer;
  [GtkChild]
  private unowned Gtk.Button quote_button;
  [GtkChild]
  private unowned PostMetrics post_metrics;
  [GtkChild]
  private unowned PostActions post_actions;

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
      text_label.selectable      = set_display_mode == MAIN;
      post_status.show_time      = set_display_mode != MAIN;
      post_status.display_inline = set_display_mode == QUOTE;
      post_metrics.visible       = set_display_mode == QUOTE;
      post_actions.visible       = set_display_mode != QUOTE;
      next_line_bin.visible      = ! (set_display_mode != LIST);
      content_box.margin_top     = set_display_mode != LIST ? 8 : 0;

      DisplayUtils.conditional_css (set_display_mode == QUOTE, text_label, "caption");
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
      displayed_post = value;
      update_item.begin ();
    }
  }

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
      Gtk.show_uri (null, item.main_post.url, Gdk.CURRENT_TIME);
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
  private async void update_item () {
    // Get the account for this widget
    var main_window = this.get_root () as MainWindow;
    Backend.Account account = main_window != null
                                ? main_window.account
                                : null;

    bool has_repost, has_quote;
    Backend.Post? repost = null, quote = null;

    // Check if we have a repost
    try {
      has_repost = displayed_post != null && displayed_post.post_type == REPOST;
      repost     = has_repost ? displayed_post : null;
      main_post  = has_repost && account != null
                     ? yield displayed_post.get_referenced_post (account)
                     : displayed_post;
    } catch (Error e) {
      warning ("Failed to pull the reposted post: $(e.message)");
    }

    // Check if we have a quote
    try {
      has_quote  = main_post != null && main_post.post_type == QUOTE;
      quote      = has_quote && account != null
                     ? yield main_post.get_referenced_post (account)
                     : null;
    } catch (Error e) {
      warning ("Failed to pull the quoted post: $(e.message)");
    }

    // Set the PostStatus widgets
    repost_status.visible     = has_repost;
    repost_status.post        = repost;
    post_status.post          = main_post;
    post_status.show_previous = has_repost;

    // Set the main post information
    string post_date   = main_post != null ? main_post.creation_date.format ("%x, %X") : "(null)";
    string post_source = main_post != null ? main_post.source : "(null)";
    info_label.label   = _("%s using %s").printf (post_date, post_source);

    // Set the main post content
    text_label.label = main_post != null ? main_post.text : "(null)";

    // Set the media previews
    bool has_media          = main_post != null && main_post.get_media ().length > 0;
    media_previewer.visible = has_media;
    if (has_media) {
      media_previewer.display_media (main_post.get_media ());
    } else {
      media_previewer.display_media (null);
    }

    // Clear existing quote from quote button
    if (quote_button.child != null) {
      quote_button.child = null;
    }

    // Add quotes in the quote button
    if (has_quote && display_mode != QUOTE) {
      var quote_item          = new PostItem ();
      quote_item.display_mode = QUOTE;
      quote_item.post         = quote;
      quote_button.child      = quote_item;
    }
    quote_button.visible = has_quote && display_mode != QUOTE;

    // Set the metrics widgets
    post_metrics.post = main_post;
    post_actions.post = main_post;
  }

  /**
   * Activated when a link in the text is clicked.
   */
  [GtkCallback]
  private bool on_link_clicked (string uri) {
    return DisplayUtils.entities_link_action (uri, this);
  }

  /**
   * Deconstructs PostItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of PostItem
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
   * Stores the post in the main view.
   */
  private Backend.Post? main_post = null;

}
