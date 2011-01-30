namespace Utils {

/* Copyright 2009-2010 Yorba Foundation
 *
 * This software is licensed under the GNU LGPL (version 2.1 or later).
 */
public uchar[] string_to_uchar_array(string str) {
    uchar[] data = new uchar[0];
    for (int ctr = 0; ctr < str.length; ctr++)
        data += (uchar) str[ctr];
   
    return data;
}

}
