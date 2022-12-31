/* LoadPage.vala
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
 * The page where the account is loaded and stored.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Authentication/LoadPage.ui")]
public class Authentication.LoadPage : Gtk.Widget {

  // UI-Elements of LoadPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;
  [GtkChild]
  private unowned Gtk.Spinner load_indicator;

  /**
   * The AuthView holding this page.
   */
  public weak AuthView view { get; construct; }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Check if children of AuthView
    if (view == null) {
      critical ("Can only be children to AuthView!");
    }

    // Connect load stop
    view.moving_back.connect (stop_load);
  }

  /**
   * Begins the load of the page.
   */
  public void begin_loading () {
    // Set the load indicator
    load_indicator.spinning = true;

    // Begin the loading
    run_loading.begin ();
  }

  /**
   * Run the loading.
   */
  private async void run_loading () {
    // Authenticate handles a lot of this now
    view.move_to_next ();
  }

  /**
   * Run when moving back.
   */
  private void stop_load () {
    // Cancel possible actions
    cancel_load.cancel ();

    // Stop load indicator
    load_indicator.spinning = false;
  }

  /**
   * Deconstructs LoadPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
    base.dispose ();
  }

  /**
   * Cancels the loading.
   */
  private Cancellable? cancel_load = null;

}
