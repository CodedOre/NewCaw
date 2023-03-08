/* PostContent.vala
 *
 * Copyright 2023 Frederick Schenk
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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/PostContent.ui")]
public class PostContent : Gtk.Widget {

  // UI-Elements of PostContent
  [GtkChild]
  private unowned Gtk.Stack content_stack;
  [GtkChild]
  private unowned Adw.StatusPage spoiler_description;
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
  public PostItem.DisplayMode display_mode {
    get {
      return set_display_mode;
    }
    construct set {
      set_display_mode = value;

      text_label.selectable = set_display_mode == MAIN;
      post_metrics.visible  = set_display_mode == QUOTE;
      post_actions.visible  = set_display_mode != QUOTE;

      DisplayUtils.conditional_css (set_display_mode == QUOTE, text_label, "caption");
    }
  }

  /**
   * The post which content is displayed in this widget.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      displayed_post = value;

      // Fill in the data
      update_item ();
    }
  }

  /**
   * If the content should be revealed.
   */
  public bool reveal_content {
    get {
      return is_content_displayed;
    }
    set {
      is_content_displayed = value;
      content_stack.visible_child_name = is_content_displayed
        ? "content"
        : "spoiler";
    }
  }

  /**
   * Updates the displayed content for a new item.
   */
  private void update_item () {
      // Check if we have a quote
      bool has_quote;
      Backend.Post? quote = null;
      has_quote = displayed_post != null && displayed_post.post_type == QUOTE;
      quote = has_quote ? displayed_post.referenced_post : null;

      // Set up the sensitivity of the post
      reveal_content = displayed_post != null ? displayed_post.sensitive == NONE : false;
      if (displayed_post != null) {
        switch (displayed_post.sensitive) {
          case ALL:
            spoiler_description.title = displayed_post.spoiler;
            break;
          case MEDIA:
            spoiler_description.title = _("Sensitive Media");
            break;
          default:
            spoiler_description.title = null;
            break;
        }
      } else {
        spoiler_description.title = _("No Content");
      }

      // Set the main post content
      text_label.label   = displayed_post != null ? displayed_post.text : "(null)";
      text_label.visible = text_label.label.length > 0;

      // Set the media previews
      bool has_media          = displayed_post != null && displayed_post.get_media ().length > 0;
      media_previewer.visible = has_media;
      if (has_media) {
        media_previewer.display_media (displayed_post.get_media ());
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
      post_metrics.post = displayed_post;
      post_actions.post = displayed_post;
  }

  /**
   * Run at initialization of the class.
   */
  class construct {
    // Set up the sensitive toggle
    install_action ("post.toggle-sensitive", null, (widget, action) => {
      // Get the instance for this
      var item = widget as PostContent;

      // Stop if post is null
      if (item.post == null) {
        return;
      }

      // Get the url and places it in the clipboard
      item.reveal_content = ! item.reveal_content;
    });
  }

  /**
   * Activated when a link in the text is clicked.
   */
  [GtkCallback]
  private bool on_link_clicked (string uri) {
    return DisplayUtils.entities_link_action (uri, this);
  }

  /**
   * Deconstructs PostContent and it's childrens.
   */
  public override void dispose () {
    // Destructs children of PostItem
    content_stack.unparent ();
    base.dispose ();
  }

  /**
   * Stores the set display mode.
   */
  private PostItem.DisplayMode set_display_mode = LIST;

  /**
   * Stores the displayed repost.
   */
  private Backend.Post? displayed_post = null;

  /**
   * If the content should be displayed.
   */
  private bool is_content_displayed;

}
