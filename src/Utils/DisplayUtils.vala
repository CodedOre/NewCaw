/* DisplayUtils.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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
 * Some Utils for displaying Content.
 */
namespace DisplayUtils {

  /**
   * Create a string representing the timespan from a certain date.
   *
   * @param datetime A GLib.DateTime which is used as reference point.
   * @param long_format Set's the output to be in a long format or not.
   *
   * @return A string showing the relative time passed since datetime.
   */
  public string display_time_delta (DateTime datetime, bool long_format = false) {
    // Get Timespan from datetime to now
    var      nowtime  = new DateTime.now ();
    TimeSpan gonetime = nowtime.difference (datetime);

    // Display time diff for minutes
    int minutes = (int)(gonetime / 1000.0 / 1000.0 / 60.0);
    if (minutes == 0) {
      return "Now";
    } else if (minutes < 60) {
      if (long_format) {
        return ngettext("%i minute ago", "%i minutes ago", minutes).printf (minutes);
      } else {
        return _("%im").printf (minutes);
      }
    }

    // Display time diff for hours
    int hours = (int)(minutes / 60.0);
    if (hours < 24) {
      if (long_format) {
        return ngettext("%i hour ago", "%i hours ago", hours).printf (hours);
      } else {
        return _("%ih").printf (hours);
      }
    }

    // Represent full date on longer timespans
    return display_date (datetime, long_format);
  }

  /**
   * Creates a string representing a specific DataTime.
   *
   * @param datetime A GLib.DateTime to be displayed.
   * @param long_format Set's the output to be in a long format or not.
   *
   * @return A string showing the specified DateTime.
   */
  public string display_date (DateTime datetime, bool long_format = false) {
    var nowtime = new DateTime.now ();

    // Only display year if it's differs from the current one
    if (datetime.get_year () == nowtime.get_year ()) {
      // TRANSLATORS: Full-text date format for dates from this years - see https://valadoc.org/glib-2.0/GLib.DateTime.format.html
      if (long_format) {
        return datetime.format (_("%e %B"));
      } else {
        return datetime.format (_("%e %b"));
      }
    } else {
      // TRANSLATORS: Full-text date format for dates from previous years - see https://valadoc.org/glib-2.0/GLib.DateTime.format.html
      if (long_format) {
        return datetime.format (_("%e %B %Y"));
      } else {
        return datetime.format (_("%e %b %y"));
      }
    }
  }

  /**
   * Adds or removes a css class from a widget according to a given condition.
   *
   * @param condition If this is true, the css class will be added to the widget.
   * @param widget The widget for which the css class should be evaluated.
   * @param css_class The CSS-class to be added or removed.
   */
  public void conditional_css (bool condition, Gtk.Widget widget, string css_class) {
    // Add css when not on widget and condition is true
    if (condition && ! widget.has_css_class (css_class)) {
      widget.add_css_class (css_class);
    }
    // Remove css when on widget and condition is false
    if (! condition && widget.has_css_class (css_class)) {
      widget.remove_css_class (css_class);
    }
  }

  /**
   * Manages the state of a button that has an style and image state toggles
   *
   * @param condition If this is true, the button will use the css_class and the "on" icon, else it
   * will not use the class and will show the "off" icon
   * @param button_content The widget for which the css class should be evaluated.
   * @param css_class The CSS-class to be added or removed
   * @param on_icon_name The image to use for "on" state
   * @param off_icon_name The image to use for "off" state
   */
  public void conditional_button_content (bool condition, Adw.ButtonContent button_content, string css_class, string on_icon_name, string off_icon_name) {
    button_content.icon_name = condition ? on_icon_name : off_icon_name;
    DisplayUtils.conditional_css (condition, button_content, css_class);
  }

  /**
   * Returns a string for a shortened version of the metric.
   *
   * @param metric The metric to be displayed.
   *
   * @return A string containing a short version of the number.
   */
  public string shortened_metric (int metric) {
    // If metric small enough, just print the integer
    if (metric < 10000) {
      return ("%'d").printf (metric);
    }
    // If not, shorten the metric and add intentifier for size
    string[] extension = { "K", "M", "B" };
    float number = metric;
    int extension_index = -1;
    while (number > 1000 && extension_index < extension.length) {
      number /= 1000;
      extension_index += 1;
    }
    // Return a string that contains not more than 5 characters
    if (number > 100) {
      return ("%'.0f%s").printf (number, extension [extension_index]);
    } else if (number > 10) {
      return ("%'.1f%s").printf (number, extension [extension_index]);
    } else {
      return ("%'.2f%s").printf (number, extension [extension_index]);
    }
  }

  /**
   * Add a "@" prefix to usernames when appropriate.
   *
   * @param user The user to be displayed.
   *
   * @return The string of the username with an "@" prefix
   */
  public string prefix_username (Backend.User user) {
    var platform = Backend.PlatformEnum.for_user (user);
    switch (platform) {
#if SUPPORT_MASTODON
      case MASTODON:
        // Only add it on Mastodon when no domain is visible
        if (user.username.contains ("@")) {
          return user.username;
        } else {
          return "@" + user.username;
        }
#endif
      default:
        return user.username;
    }
  }

  /**
   * Launches a uri from a widget.
   *
   * Used to ease the use of Gtk.UriLauncher, which replaces Gtk.show_uri.
   *
   * @param uri The uri to be opened.
   * @param widget The widget launching the uri.
   */
  public void launch_uri (string uri, Gtk.Widget widget) {
    // Get the parent window of the widget
    Gtk.Root widget_root   = widget.get_root ();
    var      parent_window = widget_root as Gtk.Window;

    // Launch the uri using UriLauncher
    var uri_launch = new Gtk.UriLauncher (uri);
    uri_launch.launch.begin (parent_window, null);
  }

  /**
   * Activated when a link in the text is clicked.
   *
   * @param uri The uri clicked in the label.
   * @param widget The widget making the call.
   *
   * @return true to signalize the link was handled.
   */
  public bool entities_link_action (string uri, Gtk.Widget widget) {
    // Run class specific actions
    if (uri.has_prefix ("hashtag|")) {
      string target = uri [8:];
      message ("Search not implemented yet, this is an dead-end!");
    }
    if (uri.has_prefix ("mention|")) {
      string target = uri [8:];
      open_mentioned_user.begin (target, widget);
    }
    if (uri.has_prefix ("weblink|")) {
      string target = uri [8:];
      launch_uri (target, widget);
    }
    return true;
  }

  /**
   * Opens a mentioned user in a new UserPage.
   *
   * @string name The name of the mentioned user.
   * @param widget The widget making the call.
   */
  private async void open_mentioned_user (string name, Gtk.Widget widget) {
    Backend.User? mention = null;

    // Get the session for the widget
    var main_window = widget.get_root () as MainWindow;
    var session = main_window != null
                    ? main_window.session
                    : null;

    if (session == null) {
      error ("Failed to get a session for this widget!");
    }

    // Load the user mentioned
    try {
      mention = yield session.pull_user_by_name (name);
    } catch (Error e) {
      warning (@"Failed to load mentioned user: $(e.message)\n");
      return;
    }

    // Open a new UserPage with the user
    if (mention != null) {
      main_window.display_user (mention);
    }
  }

}
