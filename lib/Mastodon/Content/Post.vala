/* Post.vala
 *
 * Copyright 2021 Frederick Schenk
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
 * Represents one posted status message.
 */
public class Backend.Mastodon.Post : Object, Backend.Post {

  /**
   * The unique identifier of this post.
   */
  public string id { get; }

  /**
   * The time this post was posted.
   */
  public DateTime date { get; }

  /**
   * The message of this post.
   */
  public string text { get; }

  /**
   * The text split into modules for formatting.
   */
  public TextModule[] text_modules { get; }

  /**
   * The source application who created this Post.
   */
  public string source { get; }

  /**
   * How often the post was liked.
   */
  public int64 liked_count { get; }

  /**
   * How often the post was replied to.
   */
  public int64 replied_count { get; }

  /**
   * How often this post was reposted or quoted.
   */
  public int64 reposted_count { get; }

  /**
   * Parses an given Json.Object and creates an Post object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public Post.from_json (Json.Object json) {
    // Get basic data
    _id   = json.get_string_member ("id");
    _date = new DateTime.from_iso8601 (
      json.get_string_member ("created_at"),
      new TimeZone.utc ()
    );
    Json.Object application = json.get_object_member ("application");
    _source = application.get_string_member ("name");

    // Get metrics
    _liked_count    = json.get_int_member ("favourites_count");
    _replied_count  = json.get_int_member ("replies_count");
    _reposted_count = json.get_int_member ("reblogs_count");

    // Parse the text into modules
    parse_text (json.get_string_member ("content"));
    _text = format_text ();
  }

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   * @param entities A Json.Object containing API-provided entities.
   */
  private void parse_text (string raw_text) {
    string   parsed_text = raw_text;
    string[] module_text = {};

    // Strip first paragraph symbol
    if (parsed_text [:3] == "<p>") {
      parsed_text = parsed_text [3:];
    }

    // Set line breaks
    parsed_text = parsed_text.replace ("<p>",    "\n\n");
    parsed_text = parsed_text.replace ("</p>",   "");
    parsed_text = parsed_text.replace ("<br />", "\n");

    // Create one TextModule in absent of entities
    if (! parsed_text.contains ("<span") || ! parsed_text.contains ("<a")) {
      var text_module        = TextModule ();
      text_module.type       = TEXT;
      text_module.display    = parsed_text;
      text_module.target     = null;
      text_module.text_start = 0;
      text_module.text_end   = parsed_text.length;
      _text_modules         += text_module;
      return;
    }

    // print (@"\n\n$(parsed_text)\n\n");

    // Replace html markup with parser markup
    try {
      var replace_users = new Regex ("<span class=\"h-card\"><a href=\"(.*?)\" class=\"u-url mention\">@<span>(.*?)</span></a></span>");
      var replace_tags  = new Regex ("<a href=\".*?\" class=\"mention hashtag\" rel=\"tag\">#<span>(.*?)</span></a>");
      var replace_links = new Regex ("<a href=\"(.*?)\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">.*?</span><span class=\"\">(.*?)</span><span class=\"invisible\"></span></a>");
      parsed_text = replace_users.replace (parsed_text, parsed_text.length, 0, "<modbreak/><mention name=\"@\\2\" link=\"\\1\"/><modbreak/>");
      parsed_text = replace_tags.replace  (parsed_text, parsed_text.length, 0, "<modbreak/><tag name=\"#\\1\"/><modbreak/>");
      parsed_text = replace_links.replace (parsed_text, parsed_text.length, 0, "<modbreak/><link name=\"\\2\" link=\"\\1\"/><modbreak/>");
    } catch (RegexError e) {
      error (@"Error while parsing text: $(e.message)");
    }

    // Split text into modules
    module_text     = Regex.split_simple ("<modbreak/>", parsed_text);
    uint text_index = 0;

    // Create the text modules
    foreach (string module in module_text) {
      // Parse mentions
      if (Regex.match_simple ("<mention.*?/>", module)) {
        try {
          var regex              = new Regex ("<mention name=\"(.*?)\" link=\"https://(.*?)/(.*?)\"/>");
          var text_module        = TextModule ();
          text_module.type       = MENTION;
          text_module.display    = regex.replace (module, module.length, 0, "\\1");
          text_module.target     = regex.replace (module, module.length, 0, "\\3@\\2");
          text_module.text_start = text_index;
          text_index             = text_index + text_module.display.length;
          text_module.text_end   = text_index;
          _text_modules         += text_module;
        } catch (RegexError e) {
          error (@"Error while parsing text: $(e.message)");
        }
        continue;
      }

      // Parse hashtags
      if (Regex.match_simple ("<tag.*?/>", module)) {
        try {
          var regex              = new Regex ("<tag name=\"(.*?)\"/>");
          var text_module        = TextModule ();
          text_module.type       = TAG;
          text_module.display    = regex.replace (module, module.length, 0, "\\1");
          text_module.target     = regex.replace (module, module.length, 0, "\\1");
          text_module.text_start = text_index;
          text_index             = text_index + text_module.display.length;
          text_module.text_end   = text_index;
          _text_modules         += text_module;
        } catch (RegexError e) {
          error (@"Error while parsing text: $(e.message)");
        }
        continue;
      }

      // Parse links
      if (Regex.match_simple ("<link.*?/>", module)) {
        try {
          var regex              = new Regex ("<link name=\"(.*?)\" link=\"(.*?)\"/>");
          var text_module        = TextModule ();
          text_module.type       = LINK;
          text_module.display    = regex.replace (module, module.length, 0, "\\1");
          text_module.target     = regex.replace (module, module.length, 0, "\\2");
          text_module.text_start = text_index;
          text_index             = text_index + text_module.display.length;
          text_module.text_end   = text_index;
          _text_modules         += text_module;
        } catch (RegexError e) {
          error (@"Error while parsing text: $(e.message)");
        }
        continue;
      }

      // Parse regular text
      var text_module        = TextModule ();
      text_module.type       = TEXT;
      text_module.display    = module;
      text_module.target     = null;
      text_module.text_start = text_index;
      text_index             = text_index + module.length;
      text_module.text_end   = text_index;
      _text_modules         += text_module;
    }

  }

}
