/* PlatformEnum.vala
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
 * Enumerations for the available platforms.
 *
 * Used by KeyStorage and AccountManager to request the right type when
 * loading keys or data from storage without class information.
 */
public enum PlatformEnum {

  MASTODON,
  TWITTER,
  TWITTER_LEGACY;

  /**
   * Converts the enum to a better readable string.
   */
  public string to_string() {
    switch (this) {
      case MASTODON:
        return "Mastodon";

      case TWITTER:
        return "Twitter";

      case TWITTER_LEGACY:
        return "TwitterLegacy";

      default:
        assert_not_reached();
    }
  }

  /**
   * Get the enum type for a Server.
   *
   * @param server The server to get the type for.
   *
   * @return The enum representing the platform this server is using.
   */
  public static PlatformEnum get_platform_for_server (Backend.Server server) {
    // Return if using Mastodon
    if (server is Backend.Mastodon.Server) {
      return MASTODON;
    }

    // Return if using Twitter
    if (server is Backend.Twitter.Server) {
      return TWITTER;
    }

    // Return if using TwitterLegacy
    if (server is Backend.TwitterLegacy.Server) {
      return TWITTER_LEGACY;
    }

    // Failing if not detected any platform
    assert_not_reached();
  }

  /**
   * Get the enum type for a Account.
   *
   * @param account The account to get the type for.
   *
   * @return The enum representing the platform this account is using.
   */
  public static PlatformEnum get_platform_for_account (Backend.Account account) {
    // Return if using Mastodon
    if (account is Backend.Mastodon.Account) {
      return MASTODON;
    }

    // Return if using Twitter
    if (account is Backend.Twitter.Account) {
      return TWITTER;
    }

    // Return if using TwitterLegacy
    if (account is Backend.TwitterLegacy.Account) {
      return TWITTER_LEGACY;
    }

    // Failing if not detected any platform
    assert_not_reached();
  }

}
