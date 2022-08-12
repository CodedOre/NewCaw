/* SystemInfo.vala
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
 * Provides system information for debug and troubleshooting.
 */
namespace SystemInfo {

  /**
   * Returns all information for display.
   *
   * @return A string containing all system information.
   */
  public string display_info () {
    string info_string = "";

    // Add the information
    info_string += get_application_info () + "\n";
    info_string += get_backends_info () + "\n";
    info_string += get_client_info () + "\n";

    return info_string;
  }

  /**
   * Adds information about the application.
   */
  private string get_application_info () {
    string info_string = "";

    info_string += "Application:\n";
    info_string += @"\tID: $(Config.APPLICATION_ID)\n";
    info_string += @"\tVersion: $(Config.PROJECT_VERSION)\n";

    return info_string;
  }

  /**
   * Adds information about the backends.
   */
  private string get_backends_info () {
    string info_string = "";

    info_string += "Backends:\n";
#if SUPPORT_MASTODON
    info_string += "\tMastodon: enabled\n";
#else
    info_string += "\tMastodon: disabled\n";
#endif
#if SUPPORT_TWITTER
    info_string += "\tTwitter: enabled\n";
#else
    info_string += "\tTwitter: disabled\n";
#endif

    return info_string;
  }

  /**
   * Adds information about the backend client.
   */
  private string get_client_info () {
    string info_string = "";

    string redirect_uri = Backend.Client.instance.redirect_uri != null
                            ? Backend.Client.instance.redirect_uri
                            : "(none)";

    info_string += "Backend Client:\n";
    info_string += @"\tName: $(Backend.Client.instance.name)\n";
    info_string += @"\tWebsite: $(Backend.Client.instance.website)\n";
    info_string += @"\tRedirect-URI: $(redirect_uri)\n";

    return info_string;
  }

}
