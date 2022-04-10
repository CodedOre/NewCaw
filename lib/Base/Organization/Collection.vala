/* Collection.vala
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
 * Base class for collections of Posts.
 */
public abstract class Backend.Collection : Object {

  /**
   * A ListModel holding all posts in this Collection.
   */
  public ListModel post_list { get; construct; }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public abstract async void pull_posts () throws Error;

  /**
   * The id from the latest pulled Post.
   */
  protected string? last_post_id = null;

  /**
   * An Account used to make the calls.
   */
  protected unowned Account call_account;

}
