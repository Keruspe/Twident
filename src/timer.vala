/* timer.vala
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

public class SmartTimer : Object {
	
	private double interval;
	private double elapsed = 0;
	
	public signal void timeout();
	
	public SmartTimer(uint interval) {
		this.interval = interval;
		Timeout.add_seconds(60, callback);
	}
	
	public void set_interval(double interval) {
		this.interval = interval;
		elapsed = 0;
	}
	
	private bool callback() {
		if(interval == 0)
			return true;
		
		elapsed += 60;
		
		if(elapsed >= interval) {
			elapsed = 0;
			timeout();
		}
		
		return true;
	}
}
