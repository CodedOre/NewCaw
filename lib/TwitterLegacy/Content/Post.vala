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
public class Backend.TwitterLegacy.Post : Object, Backend.Post {

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
    _id   = json.get_string_member ("id_str");
    _date = parse_time (json.get_string_member ("created_at"));

    // Get metrics
    _liked_count    = json.get_int_member ("favorite_count");
    // TODO: Add `replied_count` by counting actual replies
    _reposted_count = json.get_int_member ("retweet_count");

    // Parse the text into entities
    Json.Object? entities   = null;
    string       raw_text   = "";
    uint         text_start = 0;

    if (json.has_member ("display_text_range")) {
      Json.Array text_range = json.get_array_member ("display_text_range");
      text_start = (uint) text_range.get_int_element (0);
    }

    if (json.has_member ("full_text")) {
      raw_text = json.get_string_member ("full_text") [text_start:];
    } else {
      raw_text = json.get_string_member ("text") [text_start:];
    }

    if (json.has_member ("entities")) {
      entities = json.get_object_member ("entities");
    }

    parse_text (raw_text, entities);
    _text = format_text ();
  }

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   * @param entities A Json.Object containing API-provided entities.
   */
  private void parse_text (string raw_text, Json.Object? entities) {
    TextModule?[] main_entities = {};

    // Note all hashtags from entities
    Json.Array hashtags = entities.get_array_member ("hashtags");
    hashtags.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        Json.Object obj    = element.get_object ();
        Json.Array  length = obj.get_array_member ("indices");
        var entity         = TextModule ();
        entity.type        = TAG;
        entity.display     = "#" + obj.get_string_member ("text");
        entity.target      = "#" + obj.get_string_member ("text");
        entity.text_start  = (uint) length.get_int_element (0);
        entity.text_end    = (uint) length.get_int_element (1);
        main_entities += entity;
      }
    });

    // Note all mentions from entities
    Json.Array mentions = entities.get_array_member ("user_mentions");
    mentions.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        Json.Object obj    = element.get_object ();
        Json.Array  length = obj.get_array_member ("indices");
        var entity         = TextModule ();
        entity.type        = MENTION;
        entity.display     = "@" + obj.get_string_member ("screen_name");
        entity.target      = "@" + obj.get_string_member ("screen_name");
        entity.text_start  = (uint) length.get_int_element (0);
        entity.text_end    = (uint) length.get_int_element (1);
        main_entities += entity;
      }
    });

    // Note all links from entities
    Json.Array urls = entities.get_array_member ("urls");
    urls.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        Json.Object obj    = element.get_object ();
        Json.Array  length = obj.get_array_member ("indices");
        var entity         = TextModule ();
        entity.type        = LINK;
        entity.display     = obj.get_string_member ("display_url");
        entity.target      = obj.get_string_member ("expanded_url");
        entity.text_start  = (uint) length.get_int_element (0);
        entity.text_end    = (uint) length.get_int_element (1);
        main_entities += entity;
      }
    });

    // Convert text to one TextModule when no entities are present
    if (main_entities.length == 0) {
      var only_text        = TextModule ();
      only_text.type       = TEXT;
      only_text.display    = raw_text;
      only_text.target     = null;
      only_text.text_start = 0;
      only_text.text_end   = raw_text.length - 1;
      _text_modules       += only_text;
      return;
    }

    // Sort entities
    qsort_with_data<TextModule?> (main_entities, sizeof(TextModule?), (a, b) => {
      uint x = a.text_start;
      uint y = b.text_start;
      return (int) (x > y) - (int) (x < y);
    });

    // Split the text into TextModules
    TextModule first_entity = main_entities [0];
    if (first_entity.text_start != 0) {
      var first_text        = TextModule ();
      first_text.type       = TEXT;
      first_text.target     = null;
      first_text.text_start = 0;
      first_text.text_end   = first_entity.text_start;
      first_text.display    = raw_text [first_text.text_start:first_text.text_end];
      _text_modules        += first_text;
      _text_modules        += first_entity;
    }

    if (main_entities.length > 1) {
      for (int i = 1; i < main_entities.length; i++) {
        TextModule? last_entity    = main_entities [i-1];
        TextModule? current_entity = main_entities [i];
        if (last_entity != null && current_entity != null) {
          var text_module        = TextModule ();
          text_module.type       = TEXT;
          text_module.target     = null;
          text_module.text_start = last_entity.text_end;
          text_module.text_end   = current_entity.text_start;
          text_module.display    = raw_text [text_module.text_start:text_module.text_end];
          _text_modules         += text_module;
          _text_modules         += current_entity;
        }
      }
    }

    TextModule? last_entity = main_entities [main_entities.length - 1];
    if (last_entity != null) {
      if (last_entity.text_end < raw_text.length - 1) {
        var last_text        = TextModule ();
        last_text.type       = TEXT;
        last_text.target     = null;
        last_text.text_start = last_entity.text_end;
        last_text.text_end   = raw_text.length;
        last_text.display    = raw_text [last_text.text_start:last_text.text_end];
        _text_modules       += last_text;
      }
    }
  }

  /**
   * Parses the custom date string to a valid GLib.DateTime.
   *
   * @param text The date from the API to be converted.
   *
   * @return A GLib.DateTime with the date from the string.
   */
  private DateTime parse_time (string text) {
    // Initialize variables
    GLib.TimeZone zone = new GLib.TimeZone.utc ();
    int year, month, day, hour, minute;
    double second;

    // Check if string is valid
    if (text.length != 30) {
      // Return January 1th 2000 as default value
      warning ("Parser encountered invalid date string!");
      return new GLib.DateTime (zone, 2000, 1, 1, 0, 0, 0);
    }

    // Parse numbers from string
    year   = int.parse    (text.substring (26, 4));
    day    = int.parse    (text.substring ( 8, 2));
    hour   = int.parse    (text.substring (11, 2));
    minute = int.parse    (text.substring (14, 2));
    second = double.parse (text.substring (17, 2));

    // Parse three character month indication from string
    switch (text.substring (4, 3)) {
      case "Jan":
        month = 1;
        break;
      case "Feb":
        month = 2;
        break;
      case "Mar":
        month = 3;
        break;
      case "Apr":
        month = 4;
        break;
      case "May":
        month = 5;
        break;
      case "Jun":
        month = 6;
        break;
      case "Jul":
        month = 7;
        break;
      case "Aug":
        month = 8;
        break;
      case "Sep":
        month = 9;
        break;
      case "Oct":
        month = 10;
        break;
      case "Nov":
        month = 11;
        break;
      case "Dec":
        month = 12;
        break;
      default:
        warning ("Parser encountered invalid date string!");
        return new GLib.DateTime (zone, 2000, 1, 1, 0, 0, 0);
    }

    // Return DateTime with new values.
    GLib.DateTime result = new GLib.DateTime (zone, year, month, day, hour, minute, second);
    if (result == null) {
      warning ("Parser encountered invalid date string!");
      return new GLib.DateTime (zone, 2000, 1, 1, 0, 0, 0);
    }
    return result;
  }

}
