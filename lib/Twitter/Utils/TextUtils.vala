/* TextUtils.vala
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

using GLib;

/**
 * Contains methods used to parse text to TextModules.
 */
namespace Backend.Twitter.Utils.TextUtils {

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   * @param entities A Json.Object containing API-provided entities.
   *
   * @return A array of TextModules for format_text.
   */
  private TextModule[] parse_text (string raw_text, Json.Object? entities) {
    TextModule?[] main_entities = {};
    TextModule [] final_modules = {};

    // Parse entities when detected
    if (entities != null) {
      // Note all hashtags from entities
      if (entities.has_member ("hashtags")) {
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
            main_entities     += entity;
          }
        });
      }

      // Note all mentions from entities
      if (entities.has_member ("mentions")) {
        Json.Array mentions = entities.get_array_member ("mentions");
        mentions.foreach_element ((array, index, element) => {
          if (element.get_node_type () == OBJECT) {
            Json.Object obj    = element.get_object ();
            var entity         = TextModule ();
            entity.type        = MENTION;
            entity.display     = "@" + obj.get_string_member ("username");
            entity.target      = obj.has_member ("id") ? obj.get_string_member ("id") : "by/username/" + obj.get_string_member ("username");
            entity.text_start  = (uint) obj.get_int_member ("start");
            entity.text_end    = (uint) obj.get_int_member ("end");
            main_entities     += entity;
          }
        });
      }

      // Note all links from entities
      if (entities.has_member ("urls")) {
        bool media_included = false;
        Json.Array links = entities.get_array_member ("urls");
        links.foreach_element ((array, index, element) => {
          if (element.get_node_type () == OBJECT) {
            Json.Object obj    = element.get_object ();
            var entity         = TextModule ();
            entity.type        = WEBLINK;
            entity.display     = obj.get_string_member ("display_url");
            entity.target      = obj.get_string_member ("expanded_url");
            entity.text_start  = (uint) obj.get_int_member ("start");
            entity.text_end    = (uint) obj.get_int_member ("end");

            // Check if link is a internal link
            if (Regex.match_simple ("https://twitter.com/.*?/status/.*?", entity.target)) {
              entity.type = QUOTELINK;

              // Check if media link
              if (Regex.match_simple ("pic.twitter.com", entity.display)) {
                entity.type = MEDIALINK;
                if (media_included) {
                  // Ignore url when already included a media link
                  return;
                }
                media_included = true;
              }
            }

            main_entities     += entity;
          }
        });
      }
    }

    // Convert text to one TextModule when no entities are present
    if (main_entities.length == 0) {
      var only_text        = TextModule ();
      only_text.type       = TEXT;
      only_text.display    = raw_text;
      only_text.target     = null;
      only_text.text_start = 0;
      only_text.text_end   = raw_text.length - 1;
      return { only_text };
    }

    // Sort entities
    qsort_with_data<TextModule?> (main_entities, sizeof(TextModule?), (a, b) => {
      uint x = a.text_start;
      uint y = b.text_start;
      return (int) (x > y) - (int) (x < y);
    });

    // Create a TextModule for text before the first entity
    TextModule first_entity = main_entities [0];
    if (first_entity.text_start != 0) {
      var first_text        = TextModule ();
      first_text.type       = TEXT;
      first_text.target     = null;
      first_text.text_start = 0;
      first_text.text_end   = raw_text.index_of_nth_char (first_entity.text_start);
      first_text.display    = raw_text [first_text.text_start:first_text.text_end];
      final_modules        += first_text;
    }

    // Append the first TextModule
    final_modules += first_entity;

    // Add TextModules for each text between entities
    if (main_entities.length > 1) {
      for (int i = 1; i < main_entities.length; i++) {
        TextModule? last_entity    = main_entities [i-1];
        TextModule? current_entity = main_entities [i];
        if (last_entity != null && current_entity != null) {
          var text_module        = TextModule ();
          text_module.type       = TEXT;
          text_module.target     = null;
          text_module.text_start = raw_text.index_of_nth_char (last_entity.text_end);
          text_module.text_end   = raw_text.index_of_nth_char (current_entity.text_start);
          text_module.display    = raw_text [text_module.text_start:text_module.text_end];
          final_modules         += text_module;
          final_modules         += current_entity;
        }
      }
    }

    // Add a TextModule for text after the last entity
    TextModule? last_entity = main_entities [main_entities.length - 1];
    if (last_entity != null) {
      if (last_entity.text_end < raw_text.length - 1) {
        var last_text        = TextModule ();
        last_text.type       = TEXT;
        last_text.target     = null;
        last_text.text_start = raw_text.index_of_nth_char (last_entity.text_end);
        last_text.text_end   = raw_text.length;
        last_text.display    = raw_text [last_text.text_start:last_text.text_end];
        final_modules       += last_text;
      }
    }

    Backend.Utils.TextUtils.mark_trailing_tags (final_modules);

    return final_modules;
  }

}
