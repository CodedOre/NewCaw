/* SessionSettings.vala
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
 * Provides the subpage with the settings for a specific session.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Preferences/SessionSettings.ui")]
public class Preferences.SessionSettings : Gtk.Widget {

  // UI-Elements of SessionSettings
  [GtkChild]
  private unowned Adw.HeaderBar page_header;
  [GtkChild]
  private unowned Adw.WindowTitle page_title;
  [GtkChild]
  private unowned Adw.Clamp page_settings;

  /**
   * The session for which to set the settings.
   */
  public Backend.Session session {
    get {
      return displayed_session;
    }
    set {
      displayed_session = value;

      // Set the window title to the account names
      page_title.title    = displayed_session != null ? displayed_session.account.display_name : "(null)";
      page_title.subtitle = displayed_session != null
                              ? DisplayUtils.prefix_username (displayed_session.account)
                              : "(null)";
    }
  }

  /**
   * Run at initialization of the class.
   */
  class construct {
    // Set up the session actions
    install_action ("session-settings.remove-session", null, (widget, action) => {
      // Retrieve the active window
      var page   = widget as SessionSettings;
      var window = page.get_root () as Gtk.Window;
      if (page.session != null) {
        // Create a dialog to confirm the action
        var confirm_dialog = new Adw.MessageDialog (window,
                                                    _("Remove this Account?"),
                                                    _("This will remove the access for this account from your client."));
        confirm_dialog.add_response ("cancel", _("Cancel"));
        confirm_dialog.add_response ("remove", _("Remove Account"));
        confirm_dialog.set_default_response ("cancel");
        confirm_dialog.set_response_appearance ("remove", DESTRUCTIVE);
        confirm_dialog.response.connect (page.on_remove_dialog);
        confirm_dialog.present ();
      }
    });
  }

  /**
   * Activated by the dialog confirming the session removal.
   *
   * @param response The response given by the dialog.
   */
  private async void on_remove_dialog (string response) {
    // Do nothing if response is not "remove"
    if (response != "remove") {
      return;
    }

    // Remove the account
    try {
      yield session.revoke_session ();
    } catch (Error e) {
      error (@"Failed to remove account properly: $(e.message)");
    }

    // Close the subpage
    this.activate_action ("preferences.close-subpage", null);
  }

  /**
   * Deconstructs SessionSettings and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_header.unparent ();
    page_settings.unparent ();
    base.dispose ();
  }

  /**
   * Stores the displayed session.
   */
  private Backend.Session? displayed_session = null;

}
