/* Cawbird.vala
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

public class Cawbird : Adw.Application {

  public Cawbird () {
#if DEBUG
    Object (application_id: "uk.co.ibboard.Cawbird.Devel");
    set_resource_base_path ("/uk/co/ibboard/Cawbird/");
#else
    Object (application_id: "uk.co.ibboard.Cawbird");
#endif
  }

  protected override void activate () {}

}

int main (string[] args) {
  return new Cawbird ().run (args);
}