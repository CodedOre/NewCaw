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
  TWITTER;

  /**
   * Converts the enum to a better readable string.
   */
  public string to_string () {
    switch (this) {

      case MASTODON:
        return "Mastodon";

      case TWITTER:
        return "Twitter";

      default:
        assert_not_reached();
    }
  }

  /**
   * Get the enum from the platform name.
   *
   * @param name The name of the platform.
   *
   * @return The enum for the named platform.
   */
  public static PlatformEnum from_name (string name) {
    switch (name) {
      case "Mastodon":
        return MASTODON;
      case "Twitter":
        return TWITTER;
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
#if SUPPORT_MASTODON
    // Return if using Mastodon
    if (server is Backend.Mastodon.Server) {
      return MASTODON;
    }
#endif

#if SUPPORT_TWITTER
    // Return if using Twitter
    if (server is Backend.Twitter.Server) {
      return TWITTER;
    }
#endif

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
#if SUPPORT_MASTODON
    // Return if using Mastodon
    if (account is Backend.Mastodon.Account) {
      return MASTODON;
    }
#endif

#if SUPPORT_TWITTER
    // Return if using Twitter
    if (account is Backend.Twitter.Account) {
      return TWITTER;
    }
#endif

    // Failing if not detected any platform
    assert_not_reached();
  }

  /**
   * Get the enum type for a User.
   *
   * @param user The user to get the type for.
   *
   * @return The enum representing the platform this user is using.
   */
  public static PlatformEnum get_platform_for_user (Backend.User user) {
    // Switch method if user is an account
    if (user is Backend.Account) {
      var account = user as Backend.Account;
      return get_platform_for_account (account);
    }

#if SUPPORT_MASTODON
    // Return if using Mastodon
    if (user is Backend.Mastodon.User) {
      return MASTODON;
    }
#endif

#if SUPPORT_TWITTER
    // Return if using Twitter
    if (user is Backend.Twitter.User) {
      return TWITTER;
    }
#endif

    // Failing if not detected any platform
    assert_not_reached();
  }

}
