/* MainWindow.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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

/**
 * The main window of the application, also responsible for new windows.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/MainWindow.ui")]
public class MainWindow : Adw.ApplicationWindow {

  // UI-Elements of MainWindow
  [GtkChild]
  private unowned Gtk.Stack window_stack;
  [GtkChild]
  private unowned AuthView auth_view;
  [GtkChild]
  private unowned Adw.Leaflet main_view;
  [GtkChild]
  private unowned MainPage main_page;

  /**
   * The account currently displayed in this window.
   */
  public Backend.User account {
    get {
      return displayed_session.account;
    }
  }

  /**
   * The session currently displayed in this window.
   */
  public Backend.Session session {
    get {
      return displayed_session;
    }
    set {
      displayed_session = value;

      main_page.session = displayed_session;
      if (displayed_session != null) {
        // Display set account
        this.window_stack.set_visible_child (main_view);
        this.title = @"$(Config.PROJECT_NAME) - @$(displayed_session.account.username)";
        if (session.window_geometry.width != 0 && session.window_geometry.height != 0) {
          debug("Setting default size from session: %d×%d", session.window_geometry.width, session.window_geometry.height);
          this.default_width = session.window_geometry.width;
          this.default_height = session.window_geometry.height;
        }
      } else {
        // Or open AuthView on non-existence
        this.window_stack.set_visible_child (auth_view);
        this.title = @"$(Config.PROJECT_NAME) - Authentication";
      }
    }
  }

  /**
   * Initializes a MainWindow.
   *
   * @param app The Gtk.Application for this window.
   * @param account The account to be assigned to this window, or null for an AuthView.
   */
  public MainWindow (Gtk.Application app, Backend.Session? session = null) {
    // Initializes the Object
    Object (
      application: app,
      session: session
    );

    notify["default-width"].connect (update_default_geometry);
    notify["default-height"].connect (update_default_geometry);
  }

  private void update_default_geometry(){
    if (displayed_session != null) {
      Gtk.Allocation allocation;
      this.get_allocation (out allocation);
      displayed_session.window_geometry = Backend.WindowAllocation(){width=allocation.width, height=allocation.height};
    }
  }

  /**
   * Run at the construction of an window.
   */
  construct {
    // Handle input when authentication is closed
    auth_view.close_auth.connect (() => {
      if (auth_view.account == null) {
        // Close the window if no account was added
        this.close ();
      } else {
        // Otherwise set the new account
        this.session = auth_view.account;
        auth_view.account = null;
        auth_view.auth = null;
      }
    });
#if DEBUG
    // Add development style in debug
    this.add_css_class ("devel");
#endif
    // Increase the window count
    window_count++;
  }

  /**
   * Run at initialization of the class.
   */
  class construct {
    // Set up back button action
    install_action ("main.move-back", null, (widget, action) => {
      var window = widget as MainWindow;
      if (window != null) {
        window.main_view.navigate (BACK);
      }
    });
  }

  /**
   * Display a user in a new UserPage.
   *
   * @param user The user to be displayed.
   */
  public void display_user (Backend.User user) {
    // Check if a UserPage is active
    var current_page = main_view.visible_child as UserPage;
    if (current_page != null) {
      // Check if the user is already displayed
      if (current_page.user == user) {
        return;
      }
    }

    // Create the new page and make it visible
    var user_page = new UserPage ();
    main_view.append (user_page);
    user_page.user = user;
    main_view.set_visible_child (user_page);
  }

  /**
   * Display a post in a new ThreadPage.
   *
   * @param post The post to be displayed.
   */
  public void display_thread (Backend.Post post) {
    // Check if a ThreadPage is active
    var current_page = main_view.visible_child as ThreadPage;
    if (current_page != null) {
      // Check if the post is already displayed
      if (current_page.post == post) {
        return;
      }
    }

    // Create the new page and make it visible
    var thread_page = new ThreadPage ();
    main_view.append (thread_page);
    thread_page.post = post;
    main_view.set_visible_child (thread_page);
  }

  /**
   * Activated when the window should be closed.
   *
   * This quits the application when the last window is closed, so that at least
   * one window will be store in the session file.
   * As an TODO, this will likely need to be changed when the background
   * functionality is added, so see this as a temporarily solution so I can
   * move to other stuff first.
   *
   * @return true to stop other handlers from being invoked for the signal
   */
  public override bool close_request () {
    // Decrease the window count.
    window_count--;
    if (window_count > 0) {
      // Closes the window when more than one window is open
      this.destroy ();
    } else {
      // Quits the application when no window remains
      this.application.quit ();
    }
    return true;
  }

  /**
   * Removes the page the user has left.
   */
  [GtkCallback]
  private void on_transition () {
    // Do nothing while a transition is running
    if (main_view.child_transition_running) {
      return;
    }

    // Get the page the user left and removes it
    Gtk.Widget? left_page = main_view.get_adjacent_child (FORWARD);
    if (left_page != null) {
      main_view.remove (left_page);
    }
  }

  /**
   * Holds the displayed session.
   */
  private Backend.Session? displayed_session = null;

  /**
   * Counts how many MainWindows are opened.
   */
  private static int window_count = 0;

}
