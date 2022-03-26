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
namespace Backend.Mastodon.Utils.TextUtils {

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   *
   * @return A array of TextModules for format_text.
   */
  private TextModule[] parse_text (string raw_text) {
    string       parsed_text   = raw_text;
    string[]     module_text   = {};
    TextModule[] final_modules = {};

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
      var only_text        = TextModule ();
      only_text.type       = TEXT;
      only_text.display    = parsed_text;
      only_text.target     = null;
      only_text.text_start = 0;
      only_text.text_end   = parsed_text.length;
      return { only_text };
    }

    // Replace html markup with parser markup
    try {
      var user_regex      = new Regex ("<span class=\"h-card\"><a href=\"(.*?)\" class=\"u-url mention\">@<span>(.*?)</span></a></span>");
      var tag_regex       = new Regex ("<a href=\".*?\" class=\"mention hashtag\" rel=\"tag\">#<span>(.*?)</span></a>");
      var link_regex      = new Regex ("<a href=\"(.*?)\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">.*?</span><span class=\"\">(.*?)</span><span class=\"invisible\"></span></a>");
      var link_swap_regex = new Regex ("<a href=\"(.*?)\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">.*?</span><span class=\"\">(.*?)</span><span class=\"invisible\"></span></a>");
      parsed_text = user_regex.replace      (parsed_text, parsed_text.length, 0, "<modbreak/><mention name=\"@\\2\" link=\"\\1\"/><modbreak/>");
      parsed_text = tag_regex.replace       (parsed_text, parsed_text.length, 0, "<modbreak/><tag name=\"#\\1\"/><modbreak/>");
      parsed_text = link_regex.replace      (parsed_text, parsed_text.length, 0, "<modbreak/><link name=\"\\2\" link=\"\\1\"/><modbreak/>");
      parsed_text = link_swap_regex.replace (parsed_text, parsed_text.length, 0, "<modbreak/><link name=\"\\2\" link=\"\\1\"/><modbreak/>");
    } catch (RegexError e) {
      error (@"Error while parsing text: $(e.message)");
    }

    // Split text into modules
    module_text     = Regex.split_simple ("<modbreak/>", parsed_text);
    uint text_index = 0;

    // Create the text modules
    foreach (string module in module_text) {
      if (module == "") {
        continue;
      }

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
          final_modules        += text_module;
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
          final_modules         += text_module;
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
          text_module.type       = WEBLINK;
          text_module.display    = regex.replace (module, module.length, 0, "\\1");
          text_module.target     = regex.replace (module, module.length, 0, "\\2");
          text_module.text_start = text_index;
          text_index             = text_index + text_module.display.length;
          text_module.text_end   = text_index;
          final_modules         += text_module;
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
      final_modules         += text_module;
    }

    Backend.Utils.TextUtils.mark_trailing_tags (final_modules);

    return final_modules;
  }

}
