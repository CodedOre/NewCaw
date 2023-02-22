/* ExpandableCollection.vala
 *
 * Copyright 2023 IBBoard
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
  * Base class for collections of Posts that can load newer and older posts.
  */
 public abstract class Backend.ExpandableCollection : Backend.Collection {
    public override async void pull_posts () throws Error {
        yield pull_newer_posts ();
    }

    /**
     * Calls the API to get the newest posts for the Collection.
     *
     * @throws Error Any error that happened while pulling the posts.
     */
    public abstract async void pull_newer_posts () throws Error;

    /**
     * Calls the API to get older posts for the Collection.
     *
     * @throws Error Any error that happened while pulling the posts.
     */
    public abstract async void pull_older_posts () throws Error;

    /**
     * The id from the latest pulled Post.
     */
    protected string? last_post_id = null;

    /**
     * The id from the oldest pulled Post.
     */
    protected string? first_post_id = null;

    protected override void add_posts (Backend.Post[] posts) {
      // Load the posts in the post list
      var store = post_list as ListStore;
      foreach (Backend.Post post in posts) {
        store.insert_sorted (post, compare_items);
        // Mastodon IDs are "cast from an integer but not guaranteed to be a number",
        // Twitter "snowflake" IDs are a timestamp with extra information packed on the end,
        // so we assume that IDs are orderable
        if (last_post_id == null || post.id > last_post_id) {
          last_post_id = post.id;
        }
        if (first_post_id == null || post.id < first_post_id) {
          first_post_id = post.id;
        }
      }
    }
 }