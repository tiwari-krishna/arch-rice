from libqtile import bar, layout, widget, qtile
from libqtile.config import Click, Drag, Group, ScratchPad, DropDown, Key, Match, Screen
from libqtile.lazy import lazy
from typing import List
import subprocess
import os
import re
import socket
from tidygroups import tidygroups

mod = "mod4"
alt = "mod1"
terminal = "st"
browser = "qutebrowser"

keys = [
    Key([mod], 'g', lazy.function(tidygroups)),
    Key([mod, "shift"], "f", lazy.window.toggle_fullscreen()),
    Key([mod], "f", lazy.window.toggle_floating()),
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "BackSpace", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "q", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "space", lazy.spawn("dmenu_run"), desc="Spawn a command using dmenu"),

    # User keybinds
    Key([alt, "control"], "v", lazy.spawn(terminal + ' -e pulsemixer')),
    Key([alt, "Shift"], "s", lazy.spawn('maim -s ~/Data/screenshots/$(date +%Y-%m-%d-%s).png')),
    Key(["Shift"], "print", lazy.spawn('maim -s ~/Data/screenshots/$(date +%Y-%m-%d-%s).png')),
    Key([alt], "s", lazy.spawn('maim ~/Data/screenshots/$(date +%Y-%m-%d-%s).png')),
    Key([], "XF86AudioRaiseVolume", lazy.spawn('pamixer --allow-boost -i 3')),
    Key([], "XF86AudioLowerVolume", lazy.spawn('pamixer --allow-boost -d 3')),
    Key([], "XF86AudioMute", lazy.spawn('pamixer -t')),
    Key([], "XF86AudioPrev", lazy.spawn('mpc prev')),
    Key([], "XF86AudioNext", lazy.spawn('mpc next')),
    Key([], "XF86AudioPlay", lazy.spawn('mpc toggle')),
    Key([], "XF86MonBrightnessUp", lazy.spawn('xbacklight -inc 5%')),
    Key([], "XF86MonBrightnessDown", lazy.spawn('xbacklight -dec 5%')),
    Key([alt, mod], "Equal", lazy.spawn('xbacklight -inc 5%')),
    Key([alt, mod], "Minus", lazy.spawn('xbacklight -dec 5%')),

    Key([alt], "Up", lazy.spawn('pamixer --allow-boost -i 3')),
    Key([alt], "Down", lazy.spawn('pamixer --allow-boost -d 3')),
    Key([alt, "shift"], "space", lazy.spawn('mpc toggle')),
    Key([alt, "shift"], "Right", lazy.spawn('mpc next')),
    Key([alt, "shift"], "Left", lazy.spawn('mpc prev')),
    Key([alt, "shift"], "bracketLeft", lazy.spawn('mpc seek -60')),
    Key([alt], "bracketLeft", lazy.spawn('mpc seek -5')),
    Key([alt], "bracketRight", lazy.spawn('mpc seek +5')),
    Key([alt], "Right", lazy.spawn('mpc vol +5')),
    Key([alt], "Left", lazy.spawn('mpc vol -5')),
    Key([alt, "control"], "space", lazy.spawn('mpc single')),
    Key([alt], "apostrophe", lazy.spawn('mpc seek 0%')),

    Key([alt], "r", lazy.spawn('radio-listen')),
    Key([alt], "Menu", lazy.spawn('radio-listen')),
    Key([mod, "shift"], "BackSpace", lazy.spawn('power')),
    Key([mod], "grave", lazy.spawn('alacritty')),
    Key([alt, "shift"], "w", lazy.spawn('sxiv -q -o -t -r /home/krishna/Data/Media/wallpapers')),
    Key([mod, "shift"], "grave", lazy.spawn('libreoffice')),
    Key([mod, "shift"], "g", lazy.spawn('gimp')),
    Key([mod, "shift"], "x", lazy.spawn('pcmanfm')),
    Key([mod, "shift"], "e", lazy.spawn(terminal + ' -e htop')),
    Key([mod], "w", lazy.spawn(browser)),
    Key([mod, "shift"], "v", lazy.spawn('minitube')),
    Key([mod], "v", lazy.spawn('qbittorrent')),
    Key([mod], "c", lazy.spawn('galculator')),
    Key([mod, "control"], "r", lazy.spawn('mpv --untimed --no-cache --no-osc --no-input-default-bindings --profile=low-latency --input-conf=/dev/null --title=webcam /dev/video0')),
    Key([mod], "e", lazy.spawn('emacsclient -c || emacs')),
    Key([alt], "w", lazy.spawn(terminal + ' -e nmtui')),
    Key([mod], "a", lazy.spawn(terminal + ' -e ranger')),
    Key([mod, "shift"], "d", lazy.spawn('rofi -show drun')),
    Key([mod], "Menu", lazy.spawn('rofi -show emoji')),
    Key([mod], "slash", lazy.spawn('web-search')),
    Key([mod, "shift"], "w", lazy.spawn('open-bookmarks')),
]


groups = []

# FOR QWERTY KEYBOARDS
group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

group_labels = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι"]

group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall",]
#group_layouts = ["monadtall", "matrix", "monadtall", "bsp", "monadtall", "matrix", "monadtall", "bsp", "monadtall", "monadtall",]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))

for i in groups:
    keys.extend([

#CHANGE WORKSPACES
        Key([mod], i.name, lazy.group[i.name].toscreen()),
        Key([mod], "bracketright", lazy.screen.next_group()),
        Key([mod], "bracketleft", lazy.screen.prev_group()),

# MOVE WINDOW TO SELECTED WORKSPACE 1-10 AND STAY ON WORKSPACE
        #Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
# MOVE WINDOW TO SELECTED WORKSPACE 1-10 AND FOLLOW MOVED WINDOW TO WORKSPACE
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name) , lazy.group[i.name].toscreen()),
    ])


def init_layout_theme():
    return {"margin":5,
            "border_width":2,
            "border_focus": "#ffffff",
            "border_normal": "#4c566a"
            }

layout_theme = init_layout_theme()


layouts = [
    layout.MonadTall(**layout_theme, single_border_width=0),
    layout.MonadWide(**layout_theme, single_border_width=0),
    layout.Max(**layout_theme, ),
    layout.Floating(**layout_theme)
]

# Define scratchpads
groups.append(ScratchPad("scratchpad", [
    DropDown("term", "st", width=0.8, height=0.8, x=0.1, y=0.1, opacity=1),
    DropDown("spfm", "st -e ranger", width=0.8, height=0.8, x=0.1, y=0.1, opacity=1),
    DropDown("spmpc", "st -e ncmpcpp", width=0.8, height=0.8, x=0.1, y=0.1, opacity=1),

]))

# Scratchpad keybindings
keys.extend([
    Key([mod, "shift"], "Return", lazy.group['scratchpad'].dropdown_toggle('term')),
    Key([alt, "shift"], "Return", lazy.group['scratchpad'].dropdown_toggle('spfm')),
    Key([mod, alt], "Return", lazy.group['scratchpad'].dropdown_toggle('spmpc')),
])

widget_defaults = dict(
        font="Fira Mono Bold",
        fontsize=14,
        padding=6,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(padding=2,
                    hide_unused=True,
                    spacing=5,
                    background='#202426',
                    foreground='#a5ad00',
                    highlight_color='#034e99',
                    active='#ffffff',
                    inactive='#ffffff',
                    highlight_method='line'),
                 widget.Sep(
                        linewidth = 2,
                        foreground='#ffffff',
                        padding = 10,
                        ),
                widget.Prompt(),
                widget.CurrentLayoutIcon(
                    foreground='#ffffff',
                        ),
                widget.WindowName(fontsize=15, font='Fira Sans', background='#0d76a3'),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                # widget.StatusNotifier(),
                widget.GenPollText(update_interval=5,
                                   foreground='#eb17dd',
                                   max_chars=18,
                                   func=lambda: subprocess.check_output("/home/krishna/.local/bin/stat-music").decode("utf-8")),
                widget.OpenWeather(location='Kawasoti', format='{icon}{weather} 🌡️ {temp}`C', foreground='#1eebeb', markup=True),
                widget.Battery(format='🔋 {percent:1.0%}', update_interval=10, markup=True),
                widget.GenPollText(update_interval=3, func=lambda: subprocess.check_output("/home/krishna/.local/bin/stat-volume").decode("utf-8")),
                widget.Clock(format="📅 %b %d %a 🕛 %I:%M %p", foreground='#ebe01e', markup=True),
                widget.Systray(),
            ],
            18,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
