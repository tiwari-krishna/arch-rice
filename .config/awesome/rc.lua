pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
require("collision")()

-- No Border
screen.connect_signal("arrange", function (s)
    local max = s.selected_tag.layout.name == "max"
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if (max or only_one) and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)


-- Scratchpads Libraries
local scratch = require("scratch")
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height


-- Window Swallowing
function is_terminal(c)
    return (c.class and c.class:match("Alacritty")) and true or false
end

function copy_size(c, parent_client)
    if not c or not parent_client then
        return
    end
    if not c.valid or not parent_client.valid then
        return
    end
    c.x=parent_client.x;
    c.y=parent_client.y;
    c.width=parent_client.width;
    c.height=parent_client.height;
end
function check_resize_client(c)
    if(c.child_resize) then
        copy_size(c.child_resize, c)
    end
end

client.connect_signal("property::size", check_resize_client)
client.connect_signal("property::position", check_resize_client)
client.connect_signal("manage", function(c)
    if is_terminal(c) then
        return
    end
    local parent_client=awful.client.focus.history.get(c.screen, 1)
    if parent_client and is_terminal(parent_client) then
        parent_client.child_resize=c
        c.floating=true
        copy_size(c, parent_client)
    end
end)


-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end


-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end


-- Themes File
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Variables
terminal = "alacritty"
editor = "nvim"
browser = "librewolf"
editor_cmd = terminal .. " -e " .. editor

-- Keys Defination
modkey = "Mod4"
altkey = "Mod1"
ctrl= "Control"

-- Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}


-- Cursor follows the focus
function move_mouse_onto_focused_client()
    local c = client.focus 
    gears.timer( {  timeout = 0.1,
                autostart = true,
                single_shot = true,
                callback =  function()
                    if mouse.object_under_pointer() ~= c then
                        local geometry = c:geometry()
                        local x = geometry.x + geometry.width/2
                        local y = geometry.y + geometry.height/2
                        mouse.coords({x = x, y = y}, true)
                    end
                end } )
end


-- Create a textclock widget
mytextclock = wibox.widget.textclock (' <span color="#00a6ff">  %a %b %d</span> <span color="#fff703">  %H:%M</span>', 60)

month_calendar = awful.widget.calendar_popup.month()
month_calendar:attach( mytextclock, "tr" )

music = awful.widget.watch('sh -c "stat-music "', 5)

music:buttons(gears.table.join(
                awful.button({ }, 1 , function() awful.spawn("mpc toggle") end),
                awful.button({ }, 4 , function() awful.spawn("mpc vol +3") end),
                awful.button({ }, 5 , function() awful.spawn("mpc vol -3") end),
                awful.button({ }, 3 , function() awful.spawn( terminal .. " -e ncmpcpp") end),
                awful.button({ }, 2 , function() awful.spawn( "mpc seek 0%") end) ))


backlight = awful.widget.watch('sh -c "stat-backlight "', 5)
backlight:buttons(gears.table.join(
                awful.button({ }, 4 , function() awful.spawn("brightnessctl -e set 2%+") end),
                awful.button({ }, 5 , function() awful.spawn("brightnessctl -e set 2%-") end) ))

wifi = awful.widget.watch('sh -c "stat-wifi "', 5)
wifi:buttons(gears.table.join(
                awful.button({ }, 3 , function() awful.spawn(terminal .. " -e nmtui") end) ))

battery = awful.widget.watch('sh -c "stat-battery "', 5)

volume = awful.widget.watch('sh -c "stat-volume "', 5)
volume:buttons(gears.table.join(
                awful.button({ }, 1 , function() awful.spawn("pamixer -t") end),
                awful.button({ }, 4 , function() awful.spawn("pamixer -i 3") end),
                awful.button({ }, 5 , function() awful.spawn("pamixer vol -d 3") end),
                awful.button({ }, 3 , function() awful.spawn( terminal .. " -e pulsemixer") end),
                awful.button({ }, 2 , function() awful.spawn( "pamixer --set-volume 50") end) ))

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus  then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        style    = {
            shape = gears.shape.rounded_rect,
        },
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 22 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            spacing = 10,
            s.mylayoutbox,
            s.mypromptbox,
        },
        spacing = 10,
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
						spacing = 20,
            {{
                widget = music,
            },
            fg     = "#ff8000",
            widget = wibox.container.background
            },
            spacing = 20,
            {{
            widget = battery,
            },
            fg = "#00ff7f",
            widget = wibox.container.background
            },
            spacing = 20,
            {{
            widget = wifi,
            },
            fg = "#ff557f",
            widget = wibox.container.background
            },
            spacing = 20,
            {{
            widget = backlight,
            },
            fg = "#ff0000",
            widget = wibox.container.background
            },
            spacing = 20,
            {{
            widget = volume,
            },
            fg = "#d4ff00",
            widget = wibox.container.background
            },
            spacing = 20,
            mytextclock,
            wibox.widget.systray(),
        },
    }
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey }, "a", function () awful.util.spawn( terminal.." -e lf" ) end,
        {description = "File Manager" , group = "Terminal apps" }),
    awful.key({ modkey }, "w", function () awful.util.spawn( browser ) end,
        {description = "Web Browser" , group = "Graphical apps" }),
    awful.key({ modkey, "Shift"  }, "a", function () awful.util.spawn( terminal.." -e nvim" ) end,
        {description = "NeoVim" , group = "Terminal apps" }),
    awful.key({ altkey, }, "w", function () awful.util.spawn( terminal.." -e nmtui" ) end,
        {description = "Network Manager" , group = "Terminal apps" }),
    awful.key({ modkey, "Shift"  }, "e", function () awful.util.spawn( terminal.." -e htop" ) end,
        {description = "System Monitor" , group = "Terminal apps" }),
    awful.key({ modkey, "Control"  }, "v", function () awful.util.spawn( "pavucontrol" ) end,
        {description = "Pulsemixer" , group = "Terminal apps" }),

    awful.key({ modkey,  }, "BackSpace", function () awful.util.spawn( "xpower" ) end,
        {description = "Scripts" , group = "apps" }),
    awful.key({ altkey,  }, "Menu", function () awful.util.spawn( "xradio-listen" ) end,
        {description = "Scripts" , group = "apps" }),
    awful.key({ altkey,  }, "r", function () awful.util.spawn( "xradio-listen" ) end,
        {description = "Scripts" , group = "apps" }),
    awful.key({ modkey,  }, "space", function () awful.util.spawn( "dmenu_run" ) end,
        {description = "Run Launcher" , group = "apps" }),

    awful.key({ altkey,  }, "s", function () awful.util.spawn( "xscrshot fullscr" ) end,
        {description = "Full Screen Screenshot" , group = "Miscellanous" }),
    awful.key({ altkey, "Shift" }, "s", function () awful.util.spawn( "xscrshot sel" ) end,
        {description = "Selective Screenshot" , group = "Miscellanous" }),
    awful.key({ ctrl, "Shift" }, "s", function () awful.util.spawn( "xscrshot cpy" ) end,
        {description = "Selective Screenshot" , group = "Miscellanous" }),
    awful.key({  }, "Print", function () awful.util.spawn( "xscrshot fullscr" ) end,
        {description = "Full Screen Screenshot" , group = "Miscellanous" }),
    awful.key({ "Shift" }, "Print", function () awful.util.spawn( "xscrshot sel" ) end,
        {description = "Selective Screenshot" , group = "Miscellanous" }),
    awful.key({  }, "XF86AudioRaiseVolume", function () awful.util.spawn( "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" ) end,
        {description = "Increase Volume" , group = "Multimedia" }),
    awful.key({  }, "XF86HomePage", function () awful.util.spawn( browser ) end,
        {description = "Web Browser" , group = "Graphical App" }),
    awful.key({  }, "XF86AudioPrev", function () awful.util.spawn( "mpc prev" ) end,
        {description = "Previous Track" , group = "Multimedia" }),
    awful.key({  }, "XF86AudioNext", function () awful.util.spawn( "mpc next" ) end,
        {description = "Next Track" , group = "Multimedia" }),
    awful.key({  }, "XF86AudioPlay", function () awful.util.spawn( "mpc toggle" ) end,
        {description = "Play or Pause" , group = "Multimedia" }),
    awful.key({  }, "XF86MonBrightnessUp", function () awful.util.spawn( "brightnessctl -e set 2%+" ) end,
        {description = "Increase Brightness" , group = "Brightness" }),
    awful.key({  }, "XF86MonBrightnessDown", function () awful.util.spawn( "brightnessctl -e set 2%-" ) end,
        {description = "Decrease Brightness" , group = "Brightness" }),
    awful.key({  }, "XF86AudioLowerVolume", function () awful.util.spawn( "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" ) end,
        {description = "Decrease Volume" , group = "Multimedia" }),
    awful.key({  }, "XF86AudioMute", function () awful.util.spawn( "pamixer -t" ) end,
        {description = "Mute Output" , group = "Multimedia" }),

    awful.key({ altkey, modkey }, "equal", function () awful.util.spawn( "brightnessctl -e set 2%+" ) end,
        {description = "Increase Brightness" , group = "Brightness" }),
    awful.key({ altkey, modkey }, "minus", function () awful.util.spawn( "brightnessctl -e set 2%-" ) end,
        {description = "Decrease Brightness" , group = "Brightness" }),
    awful.key({ modkey, "Control" }, "r", function () awful.util.spawn( "webcam-show" ) end,
        {description = "MPV Webcam" , group = "Multimedia" }),
    awful.key({ modkey,    }, "u", function () awful.util.spawn( "redshift -P -O 4800" ) end,
        {description = "NightMode" , group = "Brightness" }),
    awful.key({ modkey,  "Shift"  }, "u", function () awful.util.spawn( "redshift -P -O 6300" ) end,
        {description = "NightMode" , group = "Brightness" }),

    awful.key({ altkey, }, "Up", function () awful.util.spawn( "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" ) end,
        {description = "Inc Volume" , group = "Multimedia" }),
    awful.key({ altkey, }, "Left", function () awful.util.spawn( "mpc vol -5" ) end,
        {description = "Dec MPD volume" , group = "Multimedia" }),
    awful.key({ altkey, }, "Right", function () awful.util.spawn( "mpc vol +5" ) end,
        {description = "Inc MPD volume" , group = "Multimedia" }),
    awful.key({ altkey, }, "Down", function () awful.util.spawn( "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" ) end,
        {description = "Dec MPD volume" , group = "Multimedia" }),
    awful.key({ altkey, "Shift" }, "space", function () awful.util.spawn( "mpc toggle" ) end,
        {description = "Play or Pause" , group = "Multimedia" }),
    awful.key({ altkey, "Shift" }, "Left", function () awful.util.spawn( "mpc prev" ) end,
        {description = "Previous Track" , group = "Multimedia" }),
    awful.key({ altkey, "Shift" }, "Right", function () awful.util.spawn( "mpc next" ) end,
        {description = "Next Track" , group = "Multimedia" }),
    awful.key({ altkey,  }, "bracketright", function () awful.util.spawn( "mpc seek +10" ) end,
        {description = "10s Forward" , group = "Multimedia" }),
    awful.key({ altkey, "Shift" }, "bracketright", function () awful.util.spawn( "mpc seek +60" ) end,
        {description = "60s Forward" , group = "Multimedia" }),
    awful.key({ altkey,  }, "bracketleft", function () awful.util.spawn( "mpc seek -10" ) end,
        {description = "10s Back" , group = "Multimedia" }),
    awful.key({ altkey, "Shift" }, "bracketleft", function () awful.util.spawn( "mpc seek -60" ) end,
        {description = "60s Back" , group = "Multimedia" }),
    awful.key({ altkey, "Control" }, "space", function () awful.util.spawn( "mpc single" ) end,
        {description = "Toggle single mode in MPD" , group = "Multimedia" }),

    awful.key({ altkey, }, "apostrophe", function () awful.util.spawn( "mpc seek 0%" ) end,
        {description = "Start track form beginning" , group = "Multimedia" }),

    awful.key({ altkey, "Shift" }, "w", function () awful.util.spawn( "sxiv -r -t -o -q /home/krishna/Data/Media/wallpapers" ) end,
        {description = "Wallpaper Setter" , group = "Miscellanous" }),
    awful.key({ modkey, "Shift" }, "g", function () awful.util.spawn( "gimp" ) end,
        {description = "GIMP" , group = "Graphical apps" }),
    awful.key({ modkey,  }, "grave", function () awful.util.spawn( "alacritty" ) end,
        {description = "Alacritty Terminal" , group = "Graphical apps" }),
    awful.key({ modkey, "Shift" }, "grave", function () awful.util.spawn( "libreoffice" ) end,
        {description = "Libreoffice" , group = "Graphical apps" }),
    awful.key({ modkey, "Shift" }, "d", function () awful.util.spawn( "pcmanfm" ) end,
        {description = "Graphical File Manager" , group = "Graphical apps" }),
    awful.key({ modkey, "Shift" }, "v", function () awful.util.spawn( "minitube" ) end,
        {description = "YouTube App" , group = "Graphical apps" }),
    awful.key({ modkey, "Control" }, "x", function () awful.util.spawn( "slock" ) end,
        {description = "Screen Locker" , group = "Miscellanous" }),
    awful.key({ modkey, }, "c", function () awful.util.spawn( "galculator" ) end,
        {description = "Calculator" , group = "Graphical apps" }),
    awful.key({ modkey,  }, "d", function () awful.util.spawn( terminal.." -e vid-grab" ) end,
        {description = "Media Downloader" , group = "Graphical apps" }),
    awful.key({ modkey,  }, "Menu", function () awful.util.spawn( "rofi -show emoji" ) end,
        {description = "Emoji Picker" , group = "Miscellanous" }),
    awful.key({ modkey, "Shift" }, "Menu", function () awful.util.spawn( "rofi -show drun -show-icons" ) end,
        {description = "Emoji Picker" , group = "Miscellanous" }),
    awful.key({ modkey,  }, "v", function () awful.util.spawn( terminal.." -e stig" ) end,
        {description = "Torrent Client" , group = "Graphical apps" }),
    awful.key({ modkey,  }, "b", function () awful.util.spawn( "xweb-search" ) end,
        {description = "Web-Search" , group = "Miscellanous" }),
    awful.key({ modkey, "Control" }, "w", function () awful.util.spawn( "xbrowser-launch" ) end,
        {description = "Browser-Launch" , group = "Miscellanous" }),
    awful.key({ modkey, "Shift" }, "w", function () awful.util.spawn( "xopen-bookmarks" ) end,
        {description = "Bookmarks Launcher" , group = "Miscellanous" }),

    awful.key({ modkey,        }, "z", function () awful.util.spawn( "clipmenu" ) end,
        {description = "Clipmenu" , group = "Miscellanous" }),
    awful.key({ modkey,        }, "F12", function () awful.util.spawn( "xrecording-menu" ) end,
        {description = "Recording Script" , group = "Miscellanous" }),
    awful.key({ modkey,    "Shift"  }, "F12", function () awful.util.spawn( "killall ffmpeg" ) end,
        {description = "kill FFMpeg (Recording)" , group = "Miscellanous" }),
    awful.key({ modkey,        }, "slash", function () awful.util.spawn( "xmount-drives" ) end,
        {description = "Mount Drives" , group = "Miscellanous" }),
    awful.key({ modkey,   "Shift"   }, "slash", function () awful.util.spawn( "xumount-drives" ) end,
        {description = "Unmount drives" , group = "Miscellanous" }),
    awful.key({ modkey,   "Control"   }, "slash", function () awful.util.spawn( "xmount-and" ) end,
        {description = "Mount Android Device FS" , group = "Miscellanous" }),
    awful.key({ modkey,        }, "e", function () awful.util.spawn( "qr-gen" ) end,
        {description = "Generate QR off clipboard" , group = "Miscellanous" }),
    awful.key({ altkey,        }, "m", function () awful.util.spawn( "xmovie-watch" ) end,
        {description = "Movie Menu" , group = "Miscellanous" }),
    awful.key({ modkey,        }, "semicolon", function () awful.util.spawn( "xspellchk" ) end,
        {description = "Check Spelling" , group = "Miscellanous" }),
    awful.key({ altkey,   "Shift"  }, "m", function () awful.util.spawn( "xmpv-play" ) end,
        {description = "Movie Menu" , group = "Miscellanous" }),
    awful.key({ modkey,     			}, "i", function () awful.util.spawn( "emacsclient -c" ) end,
        {description = "Emacs" , group = "Miscellanous" }),

    awful.key({ modkey,    "Shift"       }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "bracketleft",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "bracketright",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "t", function () awful.layout.set(awful.layout.suit.tile)  end,
          {description = "select tiled", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "t", function () awful.layout.set(awful.layout.suit.tile.bottom)   end,
          {description = "select bottom tiled", group = "layout"}),
    awful.key({ modkey, "Control"   }, "t", function () awful.layout.set(awful.layout.suit.floating)   end,
          {description = "select Floating", group = "layout"}),

    awful.key({ modkey,           }, "g", function()
      local screen = awful.screen.focused()
      local tnew = 1
      local aTag = screen.selected_tag.index
      for t = 1,#screen.tags do
        local clients = screen.tags[t]:clients()
        if #clients > 0 then
          for _, c in ipairs(clients) do
            c:move_to_tag(screen.tags[tnew])
          end
          if aTag == t then
            aTag = tnew
          end
          tnew = tnew + 1
        end
      end
      screen.tags[aTag]:view_only()
    end,
    {description = "reorganizetags: Shifts all clients per tag to leftmost unoccupied tags.", group = "tag"}),

    awful.key({ modkey, "Shift" }, "Return", function () scratch.toggle("alacritty --class scratch-term", { instance = "scratch-term" }) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ altkey, "Shift" }, "Return", function () scratch.toggle("alacritty --class scratch-fm -e ranger", { instance = "scratch-fm" }) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ altkey, modkey }, "Return", function () scratch.toggle("alacritty --class scratch-mpc -e ncmpcpp", { instance = "scratch-mpc" }) end,
        {description = "focus previous by index", group = "client"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1) move_mouse_onto_focused_client()
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1) move_mouse_onto_focused_client()
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) 
            move_mouse_onto_focused_client()    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)
    move_mouse_onto_focused_client()  end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ altkey,           }, "Return",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "q", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "p",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, "o",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "p",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "o",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "Tab", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Tab", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Shift" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,  "Shift"  }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, }, "s", function (c) c.sticky = not c.sticky end,
               {description = "Toggle Sticky", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey,           }, "f", function ()  awful.client.floating.toggle()  awful.placement.centered()  end,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "comma",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,  "Shift"  }, "space",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
         -- "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Galculator",
        --  "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      },
      properties = { floating = true, placement = awful.placement.centered } },

      { rule_any = { instance = { "scratch-term", "scratch-fm", "scratch-mpc" } },
      properties = { skip_taskbar = true,
            floating = true,
            placement = awful.placement.centered,
            ontop = true,
            minimized = true,
            border_width = 3,
            width = screen_width * 0.7,
            height = screen_height * 0.7,
            } },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("manage", function (c)
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
