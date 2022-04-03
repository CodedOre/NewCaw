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
 * Provides the utilities to parse HTML-encoded text to TextModules.
 */
[SingleInstance]
internal class Backend.Mastodon.Utils.TextParser : Object {

  /**
   * The instance for TextParser.
   */
  internal static TextParser instance {
    get {
      if (global_instance == null) {
        global_instance = new TextParser ();
      }
      return global_instance;
    }
  }

  /**
   * Creates an object for TextParser.
   */
  private TextParser () {
    // Initialize XML parser
    Xml.Parser.init ();
  }

  /**
   * Runs when TextParser is deconstructed.
   */
  ~TextParser () {
    // Clean up XML parser
    Xml.Parser.cleanup ();
  }

  /**
   * Parses an paragraph node and creates TextModules for it.
   *
   * @param node A pointer to the node being parsed.
   */
  private void parse_paragraph (Xml.Node* node) {
    // Spaces between tags are also nodes, discard them
    if (node->type != ELEMENT_NODE) {
      return;
    }

    // Check that node is an paragraph node
    if (node->name != "p") {
      return;
    }

    // Get the displayed text
    string paragraph_text = node->get_content ();
  }

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   *
   * @return A array of TextModules for format_text.
   */
  internal TextModule[] parse_text (string raw_text) {
    // Add root node as content can have multiple roots
    string parsed_text = @"<text>$(raw_text)</text>";

    // Create XML tree from text
    Xml.Doc* doc = Xml.Parser.parse_memory (parsed_text, parsed_text.length);
    if (doc == null) {
      error ("Failed to parse text to XML tree!");
    }
    Xml.Node* root = doc->get_root_element ();

    // Parse each paragraph node
    for (Xml.Node* paragraph = root->children; paragraph != null; paragraph = paragraph->next) {
      parse_paragraph (paragraph);
    }

    // Mark trailing tags
    Backend.Utils.TextUtils.mark_trailing_tags (text_modules);

    // Free the XML tree
    delete doc;

    return text_modules;
  }

  /**
   * Counts the chars in the text for a modules text_start and text_end.
   */
  private uint text_index = 0;

  /**
   * Contains the modules that were parsed from a text.
   */
  private TextModule[] text_modules;

  /**
   * The global instance of TextParser.
   */
  private static TextParser? global_instance = null;

}

/**
 * Contains methods used to parse text to TextModules.
 */
namespace Backend.Mastodon.Utils.TextUtils {

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   *
   * @return A array of TextModules for format_text.
   */
  private TextModule[] parse_text (string raw_text) {
    return TextParser.instance.parse_text (raw_text);
  }

}
