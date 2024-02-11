#!/bin/sh

pipewire &
mpd &
foot -s &
waybg &
gammastep -P -O 6300 &
transmission-daemon &
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
swayidle \
	timeout 5 'qtile cmd-obj -o core -f hide_cursor' resume 'qtile cmd-obj -o core -f unhide_cursor' \
	timeout 120 'wlopm --off \*' resume 'wlopm --on \*' \
	timeout 300 'swaylock -f -c 000000' &
