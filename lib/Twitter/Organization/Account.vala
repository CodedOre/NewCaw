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
public class Backend.Twitter.Account : Backend.Account {

  /**
   * Constructs an object for an Account.
   *
   * Not to be called directly, but from the static methods
   * Account.authenticate and Account.login.
   *
   * @param call_proxy The Rest.Proxy for making calls.
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   */
  private Account (Rest.OAuthProxy call_proxy, Json.Object data, Json.Object? include = null) {
    // Store the proxy in it's variable
    proxy = call_proxy;

    // Get metrics object
    Json.Object metrics = data.get_object_member ("public_metrics");

    // Parse the avatar image url
    string avatar_preview_url = data.get_string_member ("profile_image_url");
    string avatar_media_url;
    try {
      var image_regex = new Regex ("(https://pbs.twimg.com/.*?)_normal(\\..*)");
      avatar_media_url = image_regex.replace (
        avatar_preview_url,
        avatar_preview_url.length,
        0,
        "\\1\\2"
      );
    } catch (RegexError e) {
      error (@"Error while parsing source: $(e.message)");
    }

    // Get strings used to compose the url.
    string account_name = data.get_string_member ("username");

    // Construct the object with properties
    Object (
      // Set the id of the user
      id: data.get_string_member ("id"),

      // Set the account access
      access_token:  proxy.token,
      access_secret: proxy.token_secret,

      // Set the creation data
      creation_date: new DateTime.from_iso8601 (
                       data.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set the names of the user
      display_name: data.get_string_member ("name"),
      username:     account_name,

      // Set url and domain
      domain: Platform.DOMAIN,
      url:    @"https://$(Platform.DOMAIN)/$(account_name)",

      // Set metrics
      followers_count: (int) metrics.get_int_member ("followers_count"),
      following_count: (int) metrics.get_int_member ("following_count"),
      posts_count:     (int) metrics.get_int_member ("tweet_count"),

      // Set the ImageLoader for the avatar
      avatar: new Media (PICTURE, avatar_media_url, avatar_preview_url),
      header: null
    );

    // Parse text into modules
    Json.Object? description_entities = null;
    Json.Object? weblink_entity       = null;
    string       raw_text             = "";
    if (data.has_member ("description")) {
      raw_text = data.get_string_member ("description");
    }

    // Parse entities
    if (data.has_member ("entities")) {
      Json.Object account_entities = data.get_object_member ("entities");
      // Parse entities for the description
      if (account_entities.has_member ("description")) {
        description_entities = account_entities.get_object_member ("description");
      }
      // Parse entity for the linked url
      if (account_entities.has_member ("url")) {
        Json.Object account_urls = account_entities.get_object_member ("url");
        Json.Array  urls_array   = account_urls.get_array_member ("urls");
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
    if (data.has_member ("location")) {
      if (data.get_string_member ("location") != "") {
        var new_field      = UserDataField ();
        new_field.type     = LOCATION;
        new_field.name     = "Location";
        new_field.display  = data.get_string_member ("location");
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

    // Get possible flags for this user
    if (data.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (data.get_boolean_member ("verified")) {
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
    var acc_proxy = new Rest.OAuthProxy.with_token (Platform.client_key,
                                                    Platform.client_secret,
                                                    token,
                                                    secret,
                                                    "https://api.twitter.com",
                                                    false);

    // Verify access and load profile data
    Rest.ProxyCall verify_call = acc_proxy.new_call ();
    verify_call.set_function ("2/users/me");
    verify_call.add_param ("user.fields", "id,name,username,profile_image_url,protected,verified,created_at,description,entities,public_metrics,url,location,pinned_tweet_id");

    // Load the Json and create the Account
    try {
      Json.Object  json    = yield APICalls.get_data (verify_call);
      Json.Object  data    = json.get_object_member ("data");
      Json.Object? include = json.has_member ("includes") ? json.get_object_member ("data") : null;
      return new Account (acc_proxy, data, include);
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
    var acc_proxy = new Rest.OAuthProxy (Platform.client_key,
                                         Platform.client_secret,
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
    verify_call.set_function ("2/users/me");
    verify_call.add_param ("user.fields", "id,name,username,profile_image_url,protected,verified,created_at,description,entities,public_metrics,url,location,pinned_tweet_id");

    // Load the Json and create the Account
    try {
      Json.Object json     = yield APICalls.get_data (verify_call);
      Json.Object  data    = json.get_object_member ("data");
      Json.Object? include = json.has_member ("includes") ? json.get_object_member ("data") : null;
      return new Account (acc_proxy, data, include);
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
    var token_proxy = new Rest.OAuthProxy (Platform.client_key,
                                           Platform.client_secret,
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
