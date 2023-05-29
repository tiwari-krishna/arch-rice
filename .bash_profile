export BROWSER=qutebrowser
export EDITOR=nvim
export TERMINAL=foot
export HISTCONTROL=ignoredups:erasedups
export TERM="xterm-256color"
[[ $- != *i* ]] && return

export QT_QPA_PLATFORMTHEME=gtk2
export QT_QPA_PLATFORM=wayland
export GTK_THEME=Breeze-Dark
export XCURSOR_THEME="Breeze_Snow"
export XCURSOR_SIZE=35
export MOZ_USE_XINPUT2="1"
export _JAVA_AWT_WM_NONREPARENTING=1

source /etc/profile
#export PATH=$HOME/.local/bin/:$PATH
export PATH=$PATH$( find $HOME/.local/bin/ -type d -printf ":%p" )
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
export XINITRC=${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc

#[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"
[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec sway
