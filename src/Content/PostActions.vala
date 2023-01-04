/* PostActions.vala
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
 * Display post metrics and allows to perform actions on a post.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/PostActions.ui")]
public class PostActions : Gtk.Widget {

  // UI-Elements of PostMetrics
  [GtkChild]
  private unowned Gtk.Button likes_button;
  [GtkChild]
  private unowned Gtk.Button reposts_button;
  [GtkChild]
  private unowned Gtk.Button replies_button;
  [GtkChild]
  private unowned Gtk.MenuButton options_button;
  [GtkChild]
  private unowned Adw.ButtonContent likes_counter;
  [GtkChild]
  private unowned Adw.ButtonContent reposts_counter;
  [GtkChild]
  private unowned Adw.ButtonContent replies_counter;

  /**
   * The post which metrics are displayed in this widget.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      displayed_post = value;

      if (displayed_post != null) {
        likes_counter.label   = DisplayUtils.shortened_metric (displayed_post.liked_count);
        likes_button.sensitive = true;
        reposts_counter.label = DisplayUtils.shortened_metric (displayed_post.reposted_count);
        reposts_button.sensitive = true;
        replies_counter.label = DisplayUtils.shortened_metric (displayed_post.replied_count);
        replies_button.sensitive = true;

        debug("Likes: %d; Label: %s; Liked: %s", displayed_post.liked_count, likes_counter.label, displayed_post.is_favourited ? "yes" : "no");

        if (displayed_post.is_favourited) {
          likes_counter.icon_name = "liked-symbolic";
          likes_button.add_css_class ("liked");
        }
        else {
          likes_counter.icon_name = "not-liked-symbolic";
          likes_button.remove_css_class ("liked");
        }

        if (displayed_post.is_reposted) {
          reposts_counter.icon_name = "reposted-symbolic";
          reposts_button.add_css_class ("reposted");
        }
        else {
          reposts_counter.icon_name = "repost-symbolic";
          reposts_button.remove_css_class ("reposted");
        }

        string open_link_label   = _("Open on %s").printf (displayed_post.domain);
        var    post_options_menu = new Menu ();
        post_options_menu.append (open_link_label, "post.open-url");
        post_options_menu.append (_("Copy Link to Clipboard"), "post.copy-url");
        options_button.menu_model = post_options_menu;
      } else {
        likes_counter.label   =  "(null)";
        likes_button.sensitive = false;
        reposts_counter.label = "(null)";
        reposts_button.sensitive = false;
        replies_counter.label = "(null)";
        replies_button.sensitive = false;

        likes_counter.icon_name = "not-liked-symbolic";
        likes_button.remove_css_class ("liked");
        reposts_counter.icon_name = "repost-symbolic";
        reposts_button.remove_css_class ("reposted");

        options_button.menu_model = null;
      }
    }
  }

  /**
   * Deconstructs PostItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of PostItem
    likes_button.unparent ();
    reposts_button.unparent ();
    replies_button.unparent ();
    options_button.unparent ();
    base.dispose ();
  }

  [GtkCallback]
  private void like_post () {
    if (!post.is_favourited) {
      post.session.favourite_post.begin (post, (obj, res) => {
        try {
          likes_button.sensitive = true;
          var returned_post = post.session.favourite_post.end(res);
          // Update the post in case the server is one that gives us an updated object
          // FIXME: Doesn't seem to be updating!
          debug("Passing in %d likes; liked? %s", returned_post.liked_count, returned_post.is_favourited ? "yes" : "no");
          post = returned_post;
        }
        catch (Error e) {
          // pass
        }
      });
    }
    else {
      post.session.unfavourite_post.begin (post, (obj, res) => {
        try {
          likes_button.sensitive = true;
          var returned_post = post.session.unfavourite_post.end(res);
          // Update the post in case the server is one that gives us an updated object
          post = returned_post;
          debug("Passing in %d likes; liked? %s", returned_post.liked_count, returned_post.is_favourited ? "yes" : "no");
        }
        catch (Error e) {
          // pass
        }
      });
    }
    likes_button.sensitive = false;
  }

  [GtkCallback]
  private void repost_post () {
    if (!post.is_reposted) {
      post.session.reblog_post.begin (post, (obj, res) => {
        try {
          reposts_button.sensitive = true;
          var returned_post = post.session.reblog_post.end(res);
          // TBC whether we want to do anything with this - like inject it into a stream
          // TODO: Update counts based on the nested values
          // For now we set the current post back, because we don't check for change
          post = displayed_post;
        }
        catch (Error e) {
          // pass
        }
      });
    }
    else {
      post.session.unreblog_post.begin (post, (obj, res) => {
        try {
          reposts_button.sensitive = true;
          var returned_post = post.session.reblog_post.end(res);
          // FIXME: How can we pass a message up that this repost should be deleted?
          // For now we set the current post back, because we don't check for change
          post = displayed_post;
        }
        catch (Error e) {
          // pass
        }
      });
    }
    reposts_button.sensitive = false;
  }

  /**
   * Stores the displayed repost.
   */
  private Backend.Post? displayed_post = null;

}
