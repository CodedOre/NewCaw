/* DisplayUtils.vala
 *
 * Copyright 2021 Frederick Schenk
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

/**
 * Some Utils for displaying Content.
 */
namespace DisplayUtils {

  /**
   * Create a string representing the timespan from a certain date.
   *
   * @param datetime A GLib.DateTime which is used as reference point.
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

    // Display time diff for longer periods
    if (datetime.get_year () == nowtime.get_year ()) {
      // TRANSLATORS: Full-text date format for tweets from this years - see https://valadoc.org/glib-2.0/GLib.DateTime.format.html
      if (long_format) {
        return datetime.format (_("%e %B"));
      } else {
        return datetime.format (_("%e %b"));
      }
    } else {
      // TRANSLATORS: Full-text date format for tweets from previous years - see https://valadoc.org/glib-2.0/GLib.DateTime.format.html
      if (long_format) {
        return datetime.format (_("%e %B %Y"));
      } else {
        return datetime.format (_("%e %b %y"));
      }
    }
  }

}
