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
 * Represents an Profile that uses this library.
 *
 * Account extends Profile to add the
 * properties and methods to allow it to
 * interact with the API provided by the platform.
 */
public class Backend.TwitterLegacy.Account : Backend.Account {

  /**
   * Constructs an object for an Account.
   *
   * Not to be called directly, but from the static methods
   * Account.authenticate and Account.login.
   *
   * @param json The Json.Object with the account data.
   * @param call_proxy The Rest.Proxy for making calls.
   */
  private Account (Json.Object json, Rest.OAuthProxy call_proxy) {
    // Store the proxy in it's variable
    proxy = call_proxy;

    // Parse the url for avatar and header
    string avatar_preview_url = json.get_string_member ("profile_image_url_https");
    string header_preview_url = json.has_member ("profile_banner_url") ?
                                  json.get_string_member ("profile_banner_url")
                                  : null;
    string header_media_url = "", avatar_media_url;
    try {
      var image_regex = new Regex ("(https://pbs.twimg.com/.*?)_normal(\\..*)");
      avatar_media_url = image_regex.replace (
        avatar_preview_url,
        avatar_preview_url.length,
        0,
        "\\1\\2"
      );
      if (header_preview_url != null) {
        header_media_url = image_regex.replace (
          header_preview_url,
          header_preview_url.length,
          0,
          "\\1\\2"
        );
      }
    } catch (RegexError e) {
      error (@"Error while parsing source: $(e.message)");
    }

    // Get strings used to compose the url.
    string account_name = json.get_string_member ("screen_name");

    // Construct the object with properties
    Object (
      // Set the id of the account
      id: json.get_string_member ("id_str"),

      // Set the account access
      access_token:  proxy.token,
      access_secret: proxy.token_secret,

      // Set the creation data
      creation_date: Utils.parse_time (json.get_string_member ("created_at")),

      // Set the names of the account
      display_name: json.get_string_member ("name"),
      username:     account_name,

      // Set url and domain
      domain: Platform.DOMAIN,
      url:    @"https://$(Platform.DOMAIN)/$(account_name)",

      // Set metrics
      followers_count: (int) json.get_int_member ("followers_count"),
      following_count: (int) json.get_int_member ("friends_count"),
      posts_count:     (int) json.get_int_member ("statuses_count"),

      // Set the ImageLoader for the avatar
      avatar: new Media (PICTURE, avatar_media_url, avatar_preview_url),
      header: header_preview_url != null
                ? new Media (PICTURE, header_media_url, header_preview_url)
                : null
    );

    // Parse the text into modules
    Json.Object? description_entities = null;
    Json.Object? weblink_entity       = null;
    string       raw_text             = json.get_string_member ("description");

    // Parse entities
    if (json.has_member ("entities")) {
      Json.Object profile_entities = json.get_object_member ("entities");
      // Parse entities for the description
      if (profile_entities.has_member ("description")) {
        description_entities = profile_entities.get_object_member ("description");
      }
      // Parse entity for the linked url
      if (profile_entities.has_member ("url")) {
        Json.Object profile_urls = profile_entities.get_object_member ("url");
        Json.Array  urls_array   = profile_urls.get_array_member ("urls");
        // It should only have one element, so assuming this to avoid an loop
        Json.Node url_node = urls_array.get_element (0);
        if (url_node.get_node_type () == OBJECT) {
          weblink_entity = url_node.get_object ();
        }
      }
    }
    description_modules = Utils.parse_text (raw_text, description_entities);

    // First format of the description.
    description = Backend.Utils.format_text (description_modules);

    // Store additional information in data fields
    UserDataField[] additional_fields = {};
    if (json.has_member ("location")) {
      if (json.get_string_member ("location") != "") {
        var new_field      = UserDataField ();
        new_field.type     = LOCATION;
        new_field.name     = "Location";
        new_field.display  = json.get_string_member ("location");
        new_field.target   = null;
        additional_fields += new_field;
      }
    }
    if (weblink_entity != null) {
      var new_field      = UserDataField ();
      new_field.type     = WEBLINK;
      new_field.name     = "Weblink";
      new_field.display  = weblink_entity.get_string_member ("display_url");
      new_field.target   = weblink_entity.get_string_member ("expanded_url");
      additional_fields += new_field;
    }
    data_fields = additional_fields;

    // Get possible flags for this account
    if (json.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (json.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

  /**
   * Creates an Account with existing access token.
   *
   * @param token The access token for the account.
   * @param secret The secret for the access token.
   *
   * @return The constructed Account.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static async Account login (string token, string secret) throws Error {
    // Create the proxy for this Account
    var acc_proxy = new Rest.OAuthProxy.with_token (Platform.get_client_key (),
                                                    Platform.get_client_secret (),
                                                    token,
                                                    secret,
                                                    "https://api.twitter.com",
                                                    false);

    // Verify access and load profile data
    Rest.ProxyCall verify_call = acc_proxy.new_call ();
    verify_call.set_method ("GET");
    verify_call.set_function ("1.1/account/verify_credentials");

    // Load the Json and create the Account
    try {
      Json.Object json = yield APICalls.get_data (verify_call);
      return new Account (json, acc_proxy);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Finalizes a Account-authentication and creates the object.
   *
   * This constructor should be run after
   * init_authentication and use the code retrieved
   * from the site where the user authenticated himself.
   *
   * After construction, you should save the access token retrieved
   * from the platform so you can use the normal constructor.
   *
   * @param auth_code The authentication code for the user.
   *
   * @return The constructed Account.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static async Account authenticate (string auth_code) throws Error {
    // Create the proxy for this Account
    var acc_proxy = new Rest.OAuthProxy (Platform.get_client_key (),
                                         Platform.get_client_secret (),
                                         "https://api.twitter.com",
                                         false);

    // Retrieve the account key and secret
    try {
      bool token_request = yield acc_proxy.access_token_async ("oauth/access_token", auth_code, null);
      if (!token_request) {
        throw new AccountError.FAILED_TOKEN_REQUEST ("No token retrieved from API");
      }
    } catch (Error e) {
      throw e;
    }

    // Verify access and load profile data
    Rest.ProxyCall verify_call = acc_proxy.new_call ();
    verify_call.set_method ("GET");
    verify_call.set_function ("1.1/account/verify_credentials");

    // Load the Json and create the Account
    try {
      Json.Object json = yield APICalls.get_data (verify_call);
      return new Account (json, acc_proxy);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static async string init_authentication () throws Error {
    // Create call proxy
    var token_proxy = new Rest.OAuthProxy (Platform.get_client_key (),
                                           Platform.get_client_secret (),
                                           "https://api.twitter.com",
                                           false);

    // Get temporary token
    try {
      bool token_request = yield token_proxy.request_token_async ("oauth/request_token", "oob", null);
      if (!token_request) {
        throw new AccountError.FAILED_TOKEN_REQUEST ("No token retrieved from API");
      }
    } catch (Error e) {
      throw e;
    }

    // Return authentication link
    return @"$(token_proxy.url_format)/oauth/authorize?oauth_token=$(token_proxy.token)";
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
