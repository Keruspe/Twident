/* hig_table.vala
 *
 * Copyright (C) 2009-2010  troorl
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 * 	troorl <troorl@gmail.com>
 */

using Gtk;

public class HigTable : VBox {
	
	public HigTable(string title) {
		spacing = 2;
		homogeneous = false;
		
		var title_label = new Label("<b>%s</b>".printf(title));
		title_label.set_use_markup(true);
		
		var hbox = new HBox(false, 0);
		
		hbox.pack_start(title_label, false, false, 10);
		pack_start(hbox, false, false, 0);
	}
	
	public void add_widget(Widget w) {
		var hbox = new HBox(false, 0);
		hbox.pack_start(w, false, false, 20);
		pack_start(hbox, false, false, 2);
	}
	
	public void add_widget_wide(Widget w) {
		var hbox = new HBox(false, 0);
		hbox.pack_start(w, true, true, 20);
		pack_start(hbox, false, false, 2);
	}
	
	public void add_two_widgets(Widget w1, Widget w2) {
		var hbox = new HBox(false, 0);
		hbox.pack_start(w1, false, true, 20);
		hbox.pack_end(w2, false, true, 20);
		pack_start(hbox, false, false, 2);
	}
}
