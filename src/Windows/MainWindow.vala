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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Windows/MainWindow.ui")]
public class MainWindow : Adw.ApplicationWindow {

  // UI-Elements of MainWindow
  [GtkChild]
  private unowned Gtk.Stack window_stack;
  [GtkChild]
  private unowned AuthView auth_view;
  [GtkChild]
  private unowned Adw.Leaflet main_view;

  /**
   * The account currently displayed in this window.
   */
  public Backend.Account account {
    get {
      return displayed_account;
    }
    construct set {
      // Set the new account
      displayed_account = value;

      if (displayed_account != null) {
        // Display set account
        var user_page = new UserPage ();
        main_view.append (user_page);
        user_page.user = displayed_account;
        main_view.set_visible_child (user_page);
        this.window_stack.set_visible_child (main_view);
        this.title = @"$(Config.PROJECT_NAME) - @$(displayed_account.username)";
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
  public MainWindow (Gtk.Application app, Backend.Account? account = null) {
    // Initializes the Object
    Object (
      application: app,
      account:     account
    );
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
        this.account      = auth_view.account;
        auth_view.account = null;
      }
    });
#if DEBUG
    // Add development style in debug
    this.add_css_class ("devel");
#endif
  }

  /**
   * Runs at initialization of this class.
   */
  class construct {
    // Set up about action
    install_action ("app.about", null, show_about_window);
  }

  /**
   * Displays an AboutWindow for the application.
   *
   * Activated by the action "app.about".
   *
   * @param widget The widget that called the action.
   */
  private static void show_about_window (Gtk.Widget widget) {
    // Get the parent window of the widget
    Gtk.Root widget_root   = widget.get_root ();
    var      parent_window = widget_root as Gtk.Window;

    // Init the About Window
    var about_window = new Adw.AboutWindow ();

    // Set information on main page
    about_window.application_name = Config.PROJECT_NAME;
    about_window.application_icon = Config.APPLICATION_ID;
    about_window.version          = Config.PROJECT_VERSION;

    // Set information on details page
    about_window.website = "https://ibboard.co.uk/cawbird";

    // Set information on credits page
    about_window.developers = {
      "Frederick Schenk https://github.com/CodedOre",
      "IBBoard"
    };
    about_window.designers = {
      "Frederick Schenk https://github.com/CodedOre",
      "The GNOME Design Team"
    };
    about_window.artists = {
      "Micah Ilbery (Application Icon)"
    };
    about_window.translator_credits = _("Translators: Add your name here!");
    about_window.add_credit_section (
      _("Based on Corebird, created by"),
      { "Timm Bäder" }
    );

    // Set information on legal page
    about_window.copyright    = "© 2022, The Cawbird Developers";
    about_window.license_type = GPL_3_0;

    // Set information for debug
    about_window.issue_url = "https://github.com/CodedOre/NewCaw/issues";

    // Connect the AboutWindow to the parent window
    if (parent_window != null) {
      about_window.set_transient_for (parent_window);
    }

    // Display the AboutWindow
    about_window.show ();
  }

  /**
   * Holds the displayed account.
   */
  private Backend.Account displayed_account;

}
