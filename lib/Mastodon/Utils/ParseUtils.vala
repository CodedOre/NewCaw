/* ParseUtils.vala
 *
 * Copyright 2022 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Provides utilities used parsing the json of content.
 */
namespace Backend.Mastodon.Utils.ParseUtils {

  /**
   * Get the domain from a url.
   *
   * @param url The url for the domain.
   *
   * @return The domain from the url.
   */
  private string strip_domain (string url) {
    // Run a Regex to get the domain
    try {
      var regex = new Regex ("https?://(www.)?(.*?)/.*");
      return regex.replace (
        url,
        url.length,
        0,
        "\\2"
      );
    } catch (RegexError e) {
      error (@"Error while parsing domain: $(e.message)");
    }
  }

}
