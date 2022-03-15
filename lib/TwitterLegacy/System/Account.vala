/* Account.vala
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
 * Represents an User that uses this library.
 *
 * Account extends User to add the
 * properties and methods to allow it to
 * interact with the API provided by the platform.
 */
public class Backend.TwitterLegacy.Account : Backend.Account {

  /**
   * The access secret for this specific Account.
   */
  public string access_secret { get; private set; }

  /**
   * Creates an unauthenticated Account.
   *
   * After construction, it is required to either authenticate the account,
   * using the methods init_authentication and authenticate,
   * or to login with the method login.
   */
  public Account () {
    // Construct the object with server information
    Object (
      // Set server and non-authenticated
      server:        Server.instance,
      authenticated: false
    );

    // Create proxy
    proxy = new Rest.OAuthProxy (server.client_key,
                                 server.client_secret,
                                 @"https://api.$(server.domain)",
                                 false);
  }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public override async string init_authentication () throws Error {
    // Check if authentication is necessary
    if (authenticated) {
      error ("Already authenticated!");
    }

    // Get Client instance and determine used redirect uri
    Client application    = Client.instance;
    string used_redirects = application.redirect_uri != null
                              ? application.redirect_uri
                              : Server.OOB_REDIRECT;

    // Request a oauth token with the proxy
    try {
      yield proxy.request_token_async ("oauth/request_token", used_redirects, null);
    } catch (Error e) {
      throw e;
    }

    // Create authentication url
    return @"https://api.$(server.domain)/oauth/authorize?oauth_token=$(proxy.token)";
  }

  /**
   * Authenticates the account with an code.
   *
   * This method should be run after init_authentication and use
   * the code retrieved from the site where the user authenticated himself.
   *
   * After completion, you should save the access token retrieved
   * from the platform so you can use the login method on following runs.
   *
   * The optional state parameter must be provided for OAuth 2.0 authentications
   * when the Client has an redirect uri set, but is irrelevant on TwitterLegacy.
   *
   * @param auth_code The authentication code for the user.
   * @param state Ignored in this sub-class.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public override async void authenticate (string auth_code, string? state = null) throws Error {
    // Check if authentication is necessary
    if (authenticated) {
      error ("Already authenticated!");
    }

    // Retrieve the access token
    try {
      yield proxy.access_token_async ("oauth/access_token", auth_code, null);
    } catch (Error e) {
      throw e;
    }

    // Check if we retrieved a valid access token
    if (proxy.token == null || proxy.token == "") {
      error ("Could not retrieve access token!");
    } else {
      // Store the access token and secret in the properties
      access_token  = proxy.token;
      access_secret = proxy.token_secret;
    }

    // Retrieve the account user data
    var auth_call = create_call ();
    auth_call.set_method ("GET");
    auth_call.set_function ("1.1/account/verify_credentials.json");

    Json.Object data;
    try {
      data = yield server.call (auth_call);
    } catch (Error e) {
      throw e;
    }

    // Populate data with retrieved json
    set_user_data (data);
    authenticated = true;
  }

  /**
   * Creates an Account with existing access token.
   *
   * As OAuth 1.0 requires an additional secret,
   * use login_with_secret instead of this method.
   *
   * @param token The access token for the account.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public override async void login (string token) throws Error {
    critical ("Access secret not given!");
  }

  /**
   * Creates an Account with existing access token.
   *
   * As OAuth 1.0 requires an additional secret,
   * this method should be used instead of login.
   *
   * @param token The access token for the account.
   * @param secret The secret for the access token.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public async void login_with_secret (string token, string secret) throws Error {
    // Check if authentication is necessary
    if (authenticated) {
      error ("Already authenticated!");
    }

    // Set the access token on the proxy
    access_token       = token;
    access_secret      = secret;
    proxy.token        = access_token;
    proxy.token_secret = access_secret;

    // Retrieve the account user data
    var auth_call = create_call ();
    auth_call.set_method ("GET");
    auth_call.set_function ("1.1/account/verify_credentials.json");

    Json.Object data;
    try {
      data = yield server.call (auth_call);
    } catch (Error e) {
      throw e;
    }

    // Populate data with retrieved json
    set_user_data (data);
    authenticated = true;
  }

  /**
   * Sets the User data for this Account.
   *
   * @param json A Json.Object retrieved from the API.
   */
  private void set_user_data (Json.Object json) {
    // Parse the url for avatar and header
    string  avatar_preview_url = json.get_string_member ("profile_image_url_https");
    string  avatar_media_url   = Utils.ParseUtils.parse_user_image (avatar_preview_url);
    string? header_preview_url = json.has_member ("profile_banner_url")
                                  ? json.get_string_member ("profile_banner_url")
                                  : null;
    string? header_media_url   = header_preview_url != null
                                  ? Utils.ParseUtils.parse_user_image (header_preview_url)
                                  : null;

    // Get strings used to compose the url.
    string user_name = json.get_string_member ("screen_name");

    // Set the id of the user
    id = json.get_string_member ("id_str");

    // Set the creation data
    creation_date = Utils.TextUtils.parse_time (json.get_string_member ("created_at"));

    // Set the names of the user
    display_name = json.get_string_member ("name");
    username     = user_name;

    // Set url and domain
    domain = "Twitter.com";
    url    = @"https://twitter.com/$(user_name)";

    // Set metrics
    followers_count = (int) json.get_int_member ("followers_count");
    following_count = (int) json.get_int_member ("friends_count");
    posts_count     = (int) json.get_int_member ("statuses_count");

    // Set the ImageLoader for the avatar
    avatar = new Media (PICTURE, avatar_media_url, avatar_preview_url);
    header = header_preview_url != null
              ? new Media (PICTURE, header_media_url, header_preview_url)
              : null;

    // Parse the text into modules
    Json.Object? description_entities = null;
    string       raw_text             = json.get_string_member ("description");

    // Parse entities
    if (json.has_member ("entities")) {
      Json.Object user_entities = json.get_object_member ("entities");
      // Parse entities for the description
      if (user_entities.has_member ("description")) {
        description_entities = user_entities.get_object_member ("description");
      }
    }
    description_modules = Utils.TextUtils.parse_text (raw_text, description_entities);

    // First format of the description.
    description = Backend.Utils.TextUtils.format_text (description_modules);

    // Store additional information in data fields
    data_fields = Utils.ParseUtils.parse_data_fields (json);

    // Get possible flags for this user
    if (json.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (json.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

  /**
   * Creates a Rest.ProxyCall to perform an API call.
   */
  internal override Rest.ProxyCall create_call () {
    assert (proxy != null);
    return proxy.new_call ();
  }

  /**
   * The proxy used to authorize the API calls.
   */
  private Rest.OAuthProxy proxy;

}
