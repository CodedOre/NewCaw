/* config.vapi
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

/**
 * Configuration options set by meson.
 */
[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config {

  /**
   * The name of the project.
   */
	public const string PROJECT_NAME;

	/**
	 * The version of the project.
	 */
	public const string PROJECT_VERSION;

	/**
	 * The app id for the program.
	 */
	public const string APPLICATION_ID;

	/**
	 * Where the localization files are located.
	 */
	public const string LOCALEDIR;
}
