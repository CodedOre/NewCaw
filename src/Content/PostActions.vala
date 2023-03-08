/* PostActions.vala
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

  private GLib.Binding? like_count_binding;
  private GLib.Binding? repost_count_binding;
  private GLib.Binding? reply_count_binding;
  private ulong is_favourited_signal;
  private ulong is_reposted_signal;

  /**
   * The post which metrics are displayed in this widget.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      unbind(ref like_count_binding);
      unbind(ref repost_count_binding);
      unbind(ref reply_count_binding);
      if (is_favourited_signal != 0) {
        displayed_post.notify["is-favourited"].disconnect(set_like_counter_state);
        is_favourited_signal = 0;
      }
      if (is_reposted_signal != 0) {
        displayed_post.notify["is-reposted"].disconnect(set_repost_counter_state);
        is_reposted_signal = 0;
      }

      displayed_post = value;

      if (displayed_post != null) {
        like_count_binding = displayed_post.bind_property ("liked-count", likes_counter, "label", GLib.BindingFlags.SYNC_CREATE, (binding, srcval, ref targetval) => {
          int src = srcval.get_int ();
          targetval.set_string (DisplayUtils.shortened_metric (src));
          return true;
        });
        repost_count_binding = displayed_post.bind_property ("reposted-count", reposts_counter, "label", GLib.BindingFlags.SYNC_CREATE, (binding, srcval, ref targetval) => {
          int src = srcval.get_int ();
          targetval.set_string (DisplayUtils.shortened_metric (src));
          return true;
        });
        reply_count_binding = displayed_post.bind_property ("replied-count", replies_counter, "label", GLib.BindingFlags.SYNC_CREATE, (binding, srcval, ref targetval) => {
          int src = srcval.get_int ();
          targetval.set_string (DisplayUtils.shortened_metric (src));
          return true;
        });
        is_favourited_signal = displayed_post.notify["is-favourited"].connect(set_like_counter_state);
        is_favourited_signal = displayed_post.notify["is-reposted"].connect(set_repost_counter_state);

        likes_button.sensitive = true;
        reposts_button.sensitive = true;
        replies_button.sensitive = true;

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

        options_button.menu_model = null;
      }

      set_like_counter_state();
      set_repost_counter_state();
    }
  }

  private void unbind (ref GLib.Binding? binding) {
    if (binding != null) {
      binding.unbind();
      binding = null;
    }
  }

  private void set_like_counter_state () {
    DisplayUtils.conditional_button_content (displayed_post != null && displayed_post.is_favourited, likes_counter, "liked", "liked-symbolic", "not-liked-symbolic");
  }

  private void set_repost_counter_state () {
    DisplayUtils.conditional_button_content (displayed_post != null && displayed_post.is_reposted, reposts_counter, "reposted", "reposted-symbolic", "repost-symbolic");
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
      post.favourite.begin ((obj, res) => {
        try {
          post.favourite.end (res);
          likes_button.sensitive = true;
        }
        catch (Error e) {
          // TODO: Handle errors in a way that's meaningful to the user
        }
      });
    }
    else {
      post.unfavourite.begin ((obj, res) => {
        try {
          post.unfavourite.end (res);
          likes_button.sensitive = true;
        }
        catch (Error e) {
          // TODO: Handle errors in a way that's meaningful to the user
        }
      });
    }
    likes_button.sensitive = false;
  }

  [GtkCallback]
  private void repost_post () {
    if (!post.is_reposted) {
      post.reblog.begin ((obj, res) => {
        try {
          // TBC whether we want to do anything with this - like inject it into a stream
          post.reblog.end (res);
          reposts_button.sensitive = true;
        }
        catch (Error e) {
          // TODO: Handle errors in a way that's meaningful to the user
        }
      });
    }
    else {
      post.unreblog.begin ((obj, res) => {
        try {
          // TODO: How can we pass a message up that this repost should be deleted?
          post.unreblog.end (res);
          reposts_button.sensitive = true;
        }
        catch (Error e) {
          // TODO: Handle errors in a way that's meaningful to the user
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
