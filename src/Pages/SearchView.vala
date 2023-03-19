/* SearchView.vala
 *
 * Copyright 2023 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Provides the view to do a search and see the results.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Pages/SearchView.ui")]
public class SearchView : Gtk.Widget {

  // UI-Elements of SearchView
  [GtkChild]
  private unowned Gtk.SearchBar search_bar;
  [GtkChild]
  private unowned Gtk.SearchEntry search_entry;
  [GtkChild]
  private unowned CollectionView result_view;

  /**
   * The Session which is displayed.
   */
  public Backend.Session session {
    get {
      return displayed_session;
    }
    set {
      displayed_session = value;

      // Set the search entry for the active server
      search_entry.sensitive        = displayed_session != null;
      search_entry.placeholder_text = displayed_session != null
                                        ? _("Search %s").printf (displayed_session.server.domain)
                                        : _("Search not possible");
    }
  }

  [GtkCallback]
  private void perform_search () {
    string search_term     = search_entry.text;
    result_view.collection = session.get_search_list (search_term);
  }

  /**
   * Deconstructs SearchView and it's childrens.
   */
  public override void dispose () {
    // Destructs children of SearchView
    search_bar.unparent ();
    result_view.unparent ();
    base.dispose ();
  }

  /**
   * Stores the displayed session.
   */
  private Backend.Session? displayed_session = null;

  /**
   * Stores the displayed list with search results.
   */
  private Backend.SearchList? search_list = null;

}
