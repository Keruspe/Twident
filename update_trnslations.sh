#!/bin/sh

#creating template
xgettext  src/*.vala --from-code=utf-8 -k_

#updating translations
for p in $(ls po/ | grep ".po"); do
	msgmerge po/$p messages.po -o po/$p
done

rm po/pino.pot
mv messages.po po/pino.pot
