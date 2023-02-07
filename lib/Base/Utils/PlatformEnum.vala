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
public enum Backend.PlatformEnum {

#if SUPPORT_MASTODON
  MASTODON,
#endif
  NONE;

  /**
   * Converts the enum to a better readable string.
   */
  public string to_string () {
    switch (this) {

#if SUPPORT_MASTODON
      case MASTODON:
        return "Mastodon";
#endif

      case NONE:
        return "None";

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
#if SUPPORT_MASTODON
      case "Mastodon":
        return MASTODON;
#endif
      default:
        return NONE;
    }
  }

  /**
   * Get the enum type for a Server.
   *
   * @param server The server to get the type for.
   *
   * @return The enum representing the platform this server is using.
   */
  public static PlatformEnum for_server (Backend.Server server) {
#if SUPPORT_MASTODON
    // Return if using Mastodon
    if (server is Backend.Mastodon.Server) {
      return MASTODON;
    }
#endif

    // Return NONE if no platform is applicable
    return NONE;
  }

  /**
   * Get the enum type for a Session.
   *
   * @param session The session to get the type for.
   *
   * @return The enum representing the platform this session is using.
   */
  public static PlatformEnum for_session (Backend.Session session) {
#if SUPPORT_MASTODON
    // Return if using Mastodon
    if (session is Backend.Mastodon.Session) {
      return MASTODON;
    }
#endif

    // Return NONE if no platform is applicable
    return NONE;
  }

  /**
   * Get the enum type for a User.
   *
   * @param user The user to get the type for.
   *
   * @return The enum representing the platform this user is using.
   */
  public static PlatformEnum for_user (Backend.User user) {
#if SUPPORT_MASTODON
    // Return if using Mastodon
    if (user is Backend.Mastodon.User) {
      return MASTODON;
    }
#endif

    // Return NONE if no platform is applicable
    return NONE;
  }

}
