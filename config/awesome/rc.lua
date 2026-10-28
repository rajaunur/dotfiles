-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox         = require("wibox")
-- Theme handling library
local beautiful     = require("beautiful")
local dpi           = beautiful.xresources.apply_dpi
-- Notification library
local naughty       = require("naughty")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/mytheme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal   = "alacritty"
editor     = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

awful.spawn.with_shell("picom &")
awful.spawn.with_shell("pgrep -x playerctld || playerctld daemon")

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey                 = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts   = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu          = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

-- mymainmenu             = awful.menu({
--     items = {
--         { "awesome",       myawesomemenu, beautiful.awesome_icon },
--         { "open terminal", terminal }
--     }
-- })

mylauncher             = wibox.widget {
    widget = wibox.container.margin,
    right = 7,
    {

        widget = wibox.widget.textbox,
        text = "󰣇",
        resize = true,
        font = "JetBrainsMono Nerd Font 24",
        align = "center",
        -- menu = mymainmenu
    }
}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout       = awful.widget.keyboardlayout()

-- {{{ Wibar

local myclock          = wibox.widget {
    widget = wibox.container.background,
    fg = beautiful.text,
    bg = beautiful.base,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    {
        widget = wibox.container.margin,
        top = 7,
        left = 8,
        right = 7,
        bottom = 7,
        {
            layout = wibox.layout.fixed.vertical,
            wibox.widget.textclock("<span font='JetBrainsMono Nerd Font 14'>%H</span>"),
            wibox.widget.textclock("<span font='JetBrainsMono Nerd Font 14'>%M</span>"),

        }
    }
}

-- Create a wibox for each screen and add it
local taglist_buttons  = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    -- set_wallpaper(s)
    local wallpaper = "/home/rajaau/.wallpapers/blue-cat.png"
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))


    -- Create a taglist widget
    s.mytaglist = require('widgets.taglist')(s)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    local cc = require('widgets.control_center')

    -- local cc_btn = wibox.widget {
    --     widget = wibox.container.margin,
    --     left = -5,
    --     bottom = 10,
    --     {
    --         text = "",
    --         font = "JetBrainsMono Nerd Font 20",
    --         widget = wibox.widget.textbox,
    --         align = 'center',
    --         valign = 'center'
    --     }
    -- }

    mylauncher:connect_signal("mouse::enter", function()
        local w = mouse.current_wibox
        if w then
            w.cursor = "hand2"
        end
    end)

    mylauncher:connect_signal("mouse::leave", function()
        local w = mouse.current_wibox
        if w then
            w.cursor = "left_ptr"
        end
    end)

    mylauncher:buttons(gears.table.join(awful.button({}, 1, function()
        cc.visible = not cc.visible
    end)))


    awesome.connect_signal("cc::toggle", function()
        cc.visible = not cc.visible
    end)

    -- Create the wibox
    s.mywibar = awful.wibar({
        position = "left",
        x = dpi(100),
        screen = s,
        bg = "#00000000",
        width = 70,
        height = 1080
    })

    -- Add widgets to the wibox
    s.mywibar:setup {
        layout = wibox.container.margin,
        top = 15,
        bottom = 15,
        left = 10,
        right = 1,
        {
            layout = wibox.container.background,
            bg = beautiful.mantle,
            fg = beautiful.text,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 10)
            end,
            {
                layout = wibox.container.margin,
                top = 15,
                bottom = 15,
                left = 10,
                right = 10,
                {
                    layout = wibox.layout.align.vertical,
                    { -- Left widgets
                        layout = wibox.layout.fixed.vertical,
                        spacing = 20,
                        mylauncher,
                        s.mytaglist
                    },
                    {
                        layout = wibox.layout.fixed.vertical,
                        {
                            layout = wibox.container.margin,
                            top = 20,
                        }
                    },
                    { -- Right widgets
                        layout = wibox.layout.fixed.vertical,
                        spacing = 10,
                        myclock,
                        {
                            widget = wibox.container.margin,
                            margins = 5,
                            s.mylayoutbox,
                        }
                    },
                },
            },
        }
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
-- awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    -- awful.key({ modkey, }, "w", function() mymainmenu:show() end,
    --     { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --     { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey }, "p", function() awful.spawn("rofi -show drun") end,
        { description = "launcher", group = "launcher" }),
    awful.key({ "Mod1" }, "Tab", function()
        awful.spawn([[rofi -show window -selected-row 1 \
        -kb-accept-entry 'Return' \
        -kb-row-down 'Alt+Tab,Alt+Down,Down' \
        -kb-row-up 'Alt+ISO_Left_Tab,Alt+Up,Up' \
        -kb-cancel 'Escape']])
    end),
    awful.key({ modkey, "Shift" }, "p", function()
        awful.spawn(os.getenv("HOME") .. "/.config/rofi/custom/powermenu.sh")
    end, { description = "power menu", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "b", function()
        awful.spawn(os.getenv("HOME") .. "/.config/rofi/custom/bluetooth.sh")
    end, { description = "bluetooth", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "w", function()
        awful.spawn(os.getenv("HOME") .. "/.config/rofi/custom/wifi.sh")
    end, { description = "wifi", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" }),
    awful.key({ modkey, "Control" }, "t",
        function(c)
            awful.titlebar.toggle(c)
        end, { description = "toggle title bar", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

globalkeys = gears.table.join(globalkeys,

    -- Volume (F2 / F3) + mute (F1)
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")
    end, { description = "volume up", group = "media" }),

    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", vol_update)
    end, { description = "volume down", group = "media" }),

    awful.key({}, "XF86AudioMute", function()
        awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", vol_update)
    end, { description = "toggle mute", group = "media" }),

    -- Mic mute (F4)
    awful.key({}, "XF86AudioMicMute", function()
        awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
    end, { description = "toggle mic mute", group = "media" }),

    -- Brightness (F5 / F6)
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("brightnessctl set 5%+", bri_update)
    end, { description = "brightness up", group = "media" }),

    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("brightnessctl set 5%-", bri_update)
    end, { description = "brightness down", group = "media" }),

    -- My Custom
    -- awful.key({ "Mod4" }, "c", function()
    --     cc.visible = not cc.visible
    -- end, { description = "toggle control panel", group = "custom" }),

    -- Screenshot seluruh layar
    awful.key({}, "Print", function()
            awful.spawn("scrot '%Y-%m-%d-%T_screenshot.png' -e 'mv $f ~/Pictures/'")
        end,
        { description = "ambil screenshot seluruh layar dengan scrot", group = "screenshot" })

)


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer" },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
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

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    -- local buttons = gears.table.join(
    --     awful.button({}, 1, function()
    --         c:emit_signal("request::activate", "titlebar", { raise = true })
    --         awful.mouse.client.move(c)
    --     end),
    --     awful.button({}, 3, function()
    --         c:emit_signal("request::activate", "titlebar", { raise = true })
    --         awful.mouse.client.resize(c)
    --     end)
    -- )

    local function dot(color, action)
        local w = wibox.widget {
            { widget = wibox.widget.textbox },
            bg            = color,
            shape         = gears.shape.circle,
            forced_width  = 14,
            forced_height = 14,
            widget        = wibox.container.background,
        }
        w:connect_signal("mouse::enter", function() w.bg = beautiful.text end)
        w:connect_signal("mouse::leave", function() w.bg = color end)
        w:buttons(gears.table.join(awful.button({}, 1, action)))
        return wibox.widget {
            w,
            left = 4, right = 4,
            widget = wibox.container.margin,
        }
    end

    awful.titlebar(c, {
        position  = "top",
        size      = 34,
        bg_normal = beautiful.mantle,
        bg_focus  = beautiful.base,
        fg_normal = beautiful.overlay0,
        fg_focus  = beautiful.text,
    }):setup {
        layout = wibox.container.background,
        bg = beautiful.mantle,
        {
            layout = wibox.container.margin,
            left = 5,
            right = 10,
            {

                { -- Left
                    buttons = buttons,
                    layout  = wibox.layout.fixed.horizontal
                },
                { -- Middle
                    buttons = buttons,
                    layout  = wibox.layout.flex.horizontal
                },
                { -- Right
                    dot(beautiful.yellow, function() c.minimized = true end),
                    dot(beautiful.green, function()
                        c.maximized = not c.maximized; c:raise()
                    end),
                    dot(beautiful.red, function() c:kill() end),
                    layout = wibox.layout.fixed.horizontal()
                },
                layout = wibox.layout.align.horizontal
            }
        }
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
