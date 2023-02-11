/* TextUtils.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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

    // Parse all nodes beneath this one
    for (Xml.Node* child = node->children; child != null; child = child->next) {
      if (node->type != ELEMENT_NODE) {
        continue;
      }

      // Check the type of the child
      switch (child->name) {
        // Convert line breaks
        case "br":
          add_module (TEXT, "\n");
          break;

        // Parse either weblink or hashtag
        case "a":
          parse_a (child);
          break;

        // Parse a possible mention
        case "span":
          parse_mention (child);
          break;

        // Anything not detected is treated as text
        default:
          add_module (TEXT, child->get_content ());
          break;
      }
    }

    // Add two linebreaks if another paragraphs follows
    if (node->next != null) {
      add_module (TEXT, "\n\n");
    }
  }

  /**
   * Parses an "a" node for a hashtag or a weblink
   *
   * @param node A pointer to the node being parsed.
   */
  private void parse_a (Xml.Node* node) {
    // Check link properties
    for (Xml.Attr* prop = node->properties; prop != null; prop = prop->next) {
      // Check if link is marked as tag
      if (prop->name == "class") {
        string link_class = prop->children->content;
        if (link_class.contains ("hashtag")) {
          parse_hashtag (node);
          return;
        }
      }

      // Get the link to the account
      if (prop->name == "target") {
        string link_class = prop->children->content;
        if (link_class.contains ("_blank")) {
          parse_weblink (node);
          return;
        }
      }
    }

    // Add node as text if parsing failed
    warning ("Failed to parse a link node!");
    add_module (TEXT, node->get_content ());
    return;
  }

  /**
   * Parses an potential hashtag and adds it.
   *
   * @param node A pointer to the node being parsed.
   */
  private void parse_hashtag (Xml.Node* node) {
    // Create the module for the hashtag
    add_module (TAG, node->get_content (), node->get_content ());
  }

  /**
   * Parses an potential weblink and adds it.
   *
   * @param node A pointer to the node being parsed.
   */
  private void parse_weblink (Xml.Node* node) {
    // Get the target from the properties
    string? target = null;
    for (Xml.Attr* prop = node->properties; prop != null; prop = prop->next) {
      if (prop->name == "href") {
        target = prop->children->content;
      }
    }

    // Parse child nodes for display
    string display = "";
    for (Xml.Node* child = node->children; child != null; child = child->next) {
      // Check if node is marked as invisible
      bool hidden_link = false;
      for (Xml.Attr* prop = child->properties; prop != null; prop = prop->next) {
        if (prop->name == "class") {
          string link_class = prop->children->content;
          if (link_class.contains ("invisible")) {
            hidden_link = true;
          }
        }
      }

      // Set the text
      if (! hidden_link) {
        display = display + child->get_content ();
      } else if (child->prev != null) {
        // Add ellipsis when we hide parts of the url
        if (child->get_content ().length > 0) {
          display = display + "…";
        }
      }
    }

    // Add the module
    add_module (WEBLINK, display, target);
  }

  /**
   * Parses an potential mention and adds it.
   *
   * @param node A pointer to the node being parsed.
   */
  private void parse_mention (Xml.Node* node) {
    // Get the link sub-node
    Xml.Node* mention = null;
    for (Xml.Node* child = node->children; child != null; child = child->next) {
      if (child->name == "a") {
        mention = child;
      }
    }

    // Create a simple text if detection failed
    if (mention == null) {
      warning ("Failed to parse a potential mention!");
      add_module (TEXT, node->get_content ());
      return;
    }

    // Check link properties
    string? account_link = null;
    for (Xml.Attr* prop = mention->properties; prop != null; prop = prop->next) {
      // Check if link is marked as mention
      if (prop->name == "class") {
        string span_class = prop->children->content;
        if (! span_class.contains ("mention")) {
          warning ("Failed to parse a potential mention!");
          add_module (TEXT, node->get_content ());
          return;
        }
      }

      // Get the link to the account
      if (prop->name == "href") {
        account_link = prop->children->content;
      }
    }

    // Create a simple text if link parsing failed
    if (account_link == null) {
      warning ("Failed to parse a potential mention!");
      add_module (TEXT, node->get_content ());
      return;
    }

    // Create the mention module
    try {
      var    regex = new Regex ("https://(.*?)/@(.*)");
      string acct  = regex.replace (account_link, account_link.length, 0, "\\2@\\1");
      add_module (MENTION, node->get_content (), acct);
    } catch (RegexError e) {
      error (@"Error while parsing mention: $(e.message)");
    }
  }

  /**
   * Adds a new TextModule to the array.
   *
   * @param type The type of this TextModule.
   * @param display The text to be displayed.
   * @param target A possible target for this module.
   */
  private void add_module (TextModuleType type, string display, string? target = null) {
    var text_mod        = TextModule ();
    text_mod.type       = type;
    text_mod.display    = display;
    text_mod.target     = target;
    text_mod.text_start = text_index;
    text_index          = text_index + text_mod.display.length;
    text_mod.text_end   = text_index;
    text_modules       += text_mod;
  }

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   *
   * @return A array of TextModules for format_text.
   */
  internal TextModule[] parse_text (string raw_text) {
    // Reset fields
    text_modules = {};
    text_index   = 0;

    // Add root node as content can have multiple roots
    string parsed_text = @"<text>$(raw_text)</text>";

    // Replace elements we might get that Xml.Parser can't handle
    parsed_text = parsed_text.replace ("<br>", "<br/>");
    parsed_text = parsed_text.replace ("&nbsp;", "\u00A0");

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
  private uint text_index;

  /**
   * Contains the modules that were parsed from a text.
   */
  private TextModule[] text_modules;

  /**
   * The global instance of TextParser.
   */
  private static TextParser? global_instance = null;

}
