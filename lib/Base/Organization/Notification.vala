/* Notification.vala
 *
 * Copyright 2023 Frederick Schenk
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
 * Stores a notification for the user.
 */
public abstract class Backend.Notification : Object {

  /**
   * All types a Notification can have.
   */
  public enum Type {

    /**
     * A user has mentioned you in a post.
     */
    MENTION,

    /**
     * One of your post was liked.
     */
    LIKE,

    /**
     * One of your post was reposted.
     */
    REPOST,

    /**
     * A type of notification we don't really handle.
     */
    UNKNOWN

  }

  /**
   * The identifier for this notification on the system.
   */
  public string id { get; construct; }

  /**
   * The type of the notification.
   */
  public Type notification_type { get; construct; }

  /**
   * The time at which the notification was issued.
   */
  public DateTime issue_time { get; construct; }

  /**
   * The post about which the notification was send.
   */
  public Post? post { get; construct; }

  /**
   * All users about which the notification was send.
   *
   * The objects in the ListModel can be expected
   * to be of the type User.
   */
  public ListModel users { get; construct; }

}
