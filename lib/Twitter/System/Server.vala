/* Server.vala
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
 * Stores the information to connect to the Twitter server.
 *
 * As there is only one server this backend can connect to,
 * this server is created as an singleton.
 */
[SingleInstance]
public class Backend.Twitter.Server : Backend.Server {

  /**
   * The "Out-of-Band" redirect uri for Twitter.
   *
   * This uri is used when the Client does not specify an redirect url
   * to identify the API to display an authentication code
   * the user needs to manually input to authenticate the client.
   */
  // FIXME: Twitter does not have a out-of-band redirect
  internal const string OOB_REDIRECT = "https://example.com";

  /**
   * The global instance of this server.
   */
  public static Server instance {
    get {
      if (_instance == null) {
        critical ("This server was not initialized!");
      }
      return _instance;
    }
  }

  /**
   * Creates an connection with established client authentication.
   *
   * This constructor requires existing and valid client
   * keys and secrets to build the connection.
   *
   * If you do not have a key to provide, you need to generate
   * them on Twitter's Developer Portal to use here.
   *
   * @param client_key The key to authenticate the client.
   */
  public Server (string client_key) {
    // Create the Server instance
    Object (
      domain:        "twitter.com",
      client_key:    client_key,
      client_secret: "password123"  // FIXME: Testing with a fixed secret to avoid `encode_pair: assertion 'value != NULL' failed` in fetch_access_token()
    );

    // Don't set a identifier (not stored with ClientState)
    identifier = null;

    // Set the global instance
    _instance = this;
  }

  /**
   * Appends the parameters to retrieve the complete data for a post.
   *
   * This adds all parameters to a Rest.ProxyCall so
   * it requests the complete data set for a post.
   *
   * @param call A reference to the call which should get the parameters.
   */
  internal static void append_post_fields (ref Rest.ProxyCall call) {
    // All fields for a Post
    string[] post_fields = {
      "id",
      "created_at",
      "text",
      "entities",
      "author_id",
      "source",
      "conversation_id",
      "referenced_tweets",
      "public_metrics",
      "attachments"
    };

    // Add Post fields
    string post_field_param = string.joinv (",", post_fields);
    call.add_param ("tweet.fields", post_field_param);


    // All fields for Media
    string[] media_fields = {
      "media_key",
      "type",
      "width",
      "height",
      "duration_ms",
      "preview_image_url",
      "url",
      "alt_text",
      "variants"
    };

    // Add Media fields
    string media_field_param = string.joinv (",", media_fields);
    call.add_param ("media.fields", media_field_param);

    // Add User fields
    append_user_fields (ref call);

    // All extensions for a Post
    string[] post_extensions = {
      "author_id",
      "attachments.media_keys"
    };

    // Add Post extensions
    string post_extensions_param = string.joinv (",", post_extensions);
    call.add_param ("expansions", post_extensions_param);
  }

  /**
   * Appends the parameters to retrieve the complete data for a user.
   *
   * This adds all parameters to a Rest.ProxyCall so
   * it requests the complete data set for a user.
   *
   * @param call A reference to the call which should get the parameters.
   */
  internal static void append_user_fields (ref Rest.ProxyCall call) {
    // All fields to be requested
    string[] fields = {
      "id",
      "name",
      "username",
      "created_at",
      "description",
      "url",
      "entities",
      "location",
      "profile_image_url",
      "verified",
      "protected",
      "public_metrics"
    };

    // Add fields parameter
    string field_param = string.joinv (",", fields);
    call.add_param ("user.fields", field_param);
  }

  /**
   * Checks an finished Rest.ProxyCall for occurred errors.
   *
   * @param call The call as run by call.
   *
   * @throws CallError Possible detected errors.
   */
  protected override void check_call (Rest.ProxyCall call) throws CallError {
  }

  /**
   * Stores the global instance of this Server.
   */
  private static Server? _instance = null;

}
