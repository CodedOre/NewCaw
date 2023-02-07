/* UserAvatar.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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
 * A small widget displaying an avatar of an user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/UserAvatar.ui")]
public class UserAvatar : Gtk.Widget {

  // UI-Elements of UserAvatar
  [GtkChild]
  private unowned Adw.Avatar avatar_holder;
  [GtkChild]
  private unowned Gtk.Image platform_indicator;
  [GtkChild]
  private unowned Gtk.Button avatar_selector;

  /**
   * The size of this widget.
   */
  public int size { get; set; default = 48; }

  /**
   * If the widget should load the full-res avatar
   * and if this can be selected.
   */
  public bool main_mode { get; construct; }

  /**
   * If the widget should display an indicator for the
   * platform the user is on.
   */
  public bool indicate_platform { get; set; default = false; }

  /**
   * If this avatar is rounded.
   */
  public bool rounded {
    get {
      return is_rounded;
    }
    set {
      is_rounded = value;
      DisplayUtils.conditional_css (! is_rounded, avatar_holder,   "squared");
      DisplayUtils.conditional_css (! is_rounded, avatar_selector, "squared");
      DisplayUtils.conditional_css (is_rounded,   avatar_selector, "avatar-button");
    }
  }

  /**
   * The user for which to display the avatar.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      // Store the displayed user
      displayed_user = value;

      if (displayed_user == null) {
        avatar_holder.custom_image = null;
        return;
      }

      // Load and set the avatar
      if (! main_mode && displayed_user.avatar.preview_url != null) {
        displayed_user.avatar.get_preview.begin (load_cancellable, (obj, res) => {
          try {
            var paintable = displayed_user.avatar.get_preview.end (res) as Gdk.Paintable;
            avatar_holder.custom_image = paintable;
          } catch (Error e) {
            warning (@"Could not load the avatar: $(e.message)");
          }
        });
      } else {
        displayed_user.avatar.get_media.begin (load_cancellable, (obj, res) => {
          try {
            var paintable = displayed_user.avatar.get_media.end (res) as Gdk.Paintable;
            avatar_holder.custom_image = paintable;
          } catch (Error e) {
            warning (@"Could not load the avatar: $(e.message)");
          }
        });
      }

      // Set the platform indicator
      var platform = Backend.PlatformEnum.for_user (displayed_user);
      switch (platform) {
        case MASTODON:
          platform_indicator.icon_name = "platform-mastodon-symbolic";
          break;
        default:
          warning ("Failed to set the appropriate platform indicator!");
          break;
      }
      DisplayUtils.conditional_css (platform == MASTODON, platform_indicator, "mastodon-background");
    }
  }

  /**
   * Creates a new object of this widget.
   */
  public UserAvatar (bool main_avatar = false) {
    // Constructs the object
    Object (
      main_mode: main_avatar
    );
  }

  /**
   * Set's the widget up on construction.
   */
  construct {
    // Bind the settings to widget properties
    var settings = new Settings ("uk.co.ibboard.Cawbird");
    settings.bind ("round-avatars", this, "rounded",
                    GLib.SettingsBindFlags.DEFAULT);
  }

  /**
   * Runs at initialization of this class.
   */
  class construct {
    // Installs the media display action
    install_action ("avatar.display_media", null, (widget, action) => {
      // Get the instance for this
      UserAvatar display = (UserAvatar) widget;

      // Return if no avatar is set
      if (display.displayed_user == null) {
        return;
      }

      // Display the avatar in a MediaDisplay
      Backend.Media[] media  = { display.displayed_user.avatar };
      new MediaDialog (display, media);
    });
  }

  /**
   * Deconstructs UserAvatar and it's childrens.
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
    // Destructs children of UserAvatar
    avatar_holder.unparent ();
    platform_indicator.unparent ();
    avatar_selector.unparent ();
    base.dispose ();
  }

  /**
   * The displayed user.
   */
  private Backend.User? displayed_user = null;

  /**
   * A GLib.Cancellable to cancel loads when closing the item.
   */
  private Cancellable load_cancellable;

  /**
   * Stores if this avatar is rounded.
   */
  private bool is_rounded;

}
