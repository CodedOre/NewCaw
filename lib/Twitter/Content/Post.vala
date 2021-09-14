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
public class Backend.Twitter.Post : Object, Backend.Post {

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
    Json.Object data = json.get_object_member ("data");
    // Get basic data
    _id = data.get_string_member ("id");
    _date = new DateTime.from_iso8601 (
      data.get_string_member ("created_at"),
      new TimeZone.utc ()
    );

    // Get metrics
    Json.Object metrics = data.get_object_member ("public_metrics");
    _replied_count      = metrics.get_int_member ("reply_count");
    _reposted_count     = (
      metrics.get_int_member ("retweet_count") +
      metrics.get_int_member ("quote_count")
    );

    // Parse the text into modules
    Json.Object? entities   = null;
    string       raw_text   = "";

    if (data.has_member ("text")) {
      raw_text = data.get_string_member ("text");
    }
    if (data.has_member ("entities")) {
      entities = data.get_object_member ("entities");
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

    // Parse entities when detected
    if (entities != null) {
      // Note all hashtags from entities
      Json.Array hashtags = entities.get_array_member ("hashtags");
      hashtags.foreach_element ((array, index, element) => {
        if (element.get_node_type () == OBJECT) {
          Json.Object obj    = element.get_object ();
          var entity         = TextModule ();
          entity.type        = TAG;
          entity.display     = "#" + obj.get_string_member ("tag");
          entity.target      = "#" + obj.get_string_member ("tag");
          entity.text_start  = (uint) obj.get_int_member ("start");
          entity.text_end    = (uint) obj.get_int_member ("end");
          main_entities += entity;
        }
      });

      // Note all mentions from entities
      Json.Array mentions = entities.get_array_member ("mentions");
      mentions.foreach_element ((array, index, element) => {
        if (element.get_node_type () == OBJECT) {
          Json.Object obj    = element.get_object ();
          var entity         = TextModule ();
          entity.type        = MENTION;
          entity.display     = "@" + obj.get_string_member ("username");
          entity.target      = "@" + obj.get_string_member ("username");
          entity.text_start  = (uint) obj.get_int_member ("start");
          entity.text_end    = (uint) obj.get_int_member ("end");
          main_entities += entity;
        }
      });

      // Note all links from entities
      Json.Array links = entities.get_array_member ("urls");
      links.foreach_element ((array, index, element) => {
        if (element.get_node_type () == OBJECT) {
          Json.Object obj    = element.get_object ();
          var entity         = TextModule ();
          entity.type        = LINK;
          entity.display     = obj.get_string_member ("display_url");
          entity.target      = obj.get_string_member ("expanded_url");
          entity.text_start  = (uint) obj.get_int_member ("start");
          entity.text_end    = (uint) obj.get_int_member ("end");
          main_entities += entity;
        }
      });
    }

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

}
