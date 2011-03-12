/* time_parser.c
 *
 * Copyright (C) 2007-2008 Daniel Morales <daniminas@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * Authors: Daniel Morales <daniminas@gmail.com>
 *
 */

/** It was taken from twitux and modofied by me (troorl@gmail.com) */

#include "time_parser.h"

int time_to_diff(const gchar *datetime, gboolean atom)
{
	struct tm	*ta;
	struct tm	 post;
	int			 seconds_local;
	int			 seconds_post;
	int 		 diff;
	time_t		 t = time(NULL);

	tzset();

	ta = gmtime(&t);
	ta->tm_isdst = -1;
	seconds_local = mktime(ta);
	
	if(atom)
		strptime(datetime, "%Y-%m-%dT%TZ", &post);
	else
		strptime(datetime, "%a %b %d %T +0000 %Y", &post);
	post.tm_isdst = -1;
	seconds_post =  mktime(&post);

	diff = difftime(seconds_local, seconds_post);
	
	return diff;
}
