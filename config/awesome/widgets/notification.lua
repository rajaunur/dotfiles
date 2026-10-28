local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi

local function col(key, fallback) return beautiful[key] or fallback end
local C             = {
    base     = col("bg_normal", "#1e1e2e"),
    surface0 = col("bg_focus", "#313244"),
    overlay  = col("fg_minimize", "#6c7086"),
    text     = col("fg_normal", "#cdd6f4"),
    subtext  = "#a6adc8",
    mauve    = col("border_focus", "#cba6f7"),
    red      = "#f38ba8",
}
local FONT          = "JetBrainsMono Nerd Font"
local MAX_STORE     = 50 -- maksimal notifikasi yang disimpan
local PER_PAGE      = 5  -- yang ditampilkan sekaligus (scroll buat geser)

local items, offset = {}, 0

local list          = wibox.widget { spacing = dpi(8), layout = wibox.layout.fixed.vertical }
local count_lbl     = wibox.widget { font = FONT .. " 11", widget = wibox.widget.textbox }

local render -- forward declaration

local function make_item(it, idx)
    local icon = wibox.widget {
        image = it.icon, resize = true,
        forced_width = dpi(36), forced_height = dpi(36),
        clip_shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(6)) end,
        widget = wibox.widget.imagebox,
    }
    if not it.icon then icon.image = nil end
    local title = wibox.widget {
        font = FONT .. "SemiBold 12", ellipsize = "end", widget = wibox.widget.textbox,
    }
    title:set_markup_silently("<span foreground='" .. C.text .. "'>"
        .. gears.string.xml_escape(it.title ~= "" and it.title or it.app) .. "</span>")

    local msg = wibox.widget { font = FONT .. " 13", ellipsize = "end", widget = wibox.widget.textbox }
    if not msg:set_markup_silently("<span foreground='" .. C.subtext .. "'>" .. it.message .. "</span>") then
        msg.text = it.message
    end

    local meta = wibox.widget {
        markup = "<span foreground='" .. C.overlay .. "'>" .. gears.string.xml_escape(it.app)
            .. "  ·  " .. it.time .. "</span>",
        font = FONT .. " 10", widget = wibox.widget.textbox,
    }

    local close = wibox.widget { text = " ", font = FONT .. " 13", fg = C.overlay,
        widget = wibox.widget.textbox }
    local close_bg = wibox.widget { close, fg = C.overlay, widget = wibox.container.background }
    close_bg:connect_signal("mouse::enter", function() close_bg.fg = C.red end)
    close_bg:connect_signal("mouse::leave", function() close_bg.fg = C.overlay end)
    close_bg:buttons(gears.table.join(awful.button({}, 1, function()
        for i, x in ipairs(items) do
            if x == it then
                table.remove(items, i)
                break
            end
        end
        render()
    end)))

    return wibox.widget {
        {
            {
                icon,
                {
                    { title, meta, msg, spacing = dpi(1), layout = wibox.layout.fixed.vertical },
                    width = dpi(220), strategy = "max", widget = wibox.container.constraint,
                },
                {
                    widget = wibox.container.margin,
                    top = dpi(-40),
                    right = dpi(5),
                    close_bg,
                },
                spacing = dpi(10), layout = wibox.layout.align.horizontal,
            },
            top = dpi(10),
            left = dpi(-20),
            right = dpi(5),
            bottom = dpi(10),
            widget = wibox.container.margin,
        },
        bg = C.surface0,
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(8)) end,
        widget = wibox.container.background,
    }
end

function render()
    list:reset()
    count_lbl.markup = "<span foreground='" .. C.overlay .. "'>" .. #items .. " notifications</span>"

    if #items == 0 then
        list:add(wibox.widget {
            markup = "<span foreground='" .. C.overlay .. "'>No Notifications</span>",
            font = FONT .. " 11", align = "center", forced_height = dpi(60),
            widget = wibox.widget.textbox,
        })
        return
    end

    offset = math.max(0, math.min(offset, math.max(0, #items - PER_PAGE)))
    for i = offset + 1, math.min(#items, offset + PER_PAGE) do
        list:add(make_item(items[i], i))
    end
end

-- scroll mouse buat geser halaman
list:buttons(gears.table.join(
    awful.button({}, 4, function()
        offset = offset - 1; render()
    end),
    awful.button({}, 5, function()
        offset = offset + 1; render()
    end)
))

-- tangkap setiap notifikasi masuk
local function push(app, title, message, icon)
    table.insert(items, 1, {
        app     = (app and app ~= "") and app or "system",
        title   = title or "",
        message = message or "",
        icon    = icon,
        time    = os.date("%H:%M"),
    })
    while #items > MAX_STORE do table.remove(items) end
    offset = 0
    render()
end

if naughty.connect_signal then
    -- awesome-git
    naughty.connect_signal("added", function(n)
        push(n.app_name, n.title, n.message, type(n.icon) == "string" and n.icon or nil)
    end)
else
    -- awesome 4.3 rilis
    local prev = naughty.config.notify_callback
    naughty.config.notify_callback = function(args)
        if prev then args = prev(args) end
        if args then
            push(args.appname or args.app_name, args.title,
                args.text or args.message,
                type(args.icon) == "string" and args.icon or nil)
        end
        args.icon = nil
        return args -- return nil di sini kalau mau tanpa pop-up, cuma masuk control center
    end
end

-- header: clear all + do not disturb
local function header_btn(text, onclick)
    local t = wibox.widget { text = text, font = FONT .. " 10", widget = wibox.widget.textbox }
    local bg = wibox.widget { t, fg = C.subtext, widget = wibox.container.background }
    bg:connect_signal("mouse::enter", function() bg.fg = C.mauve end)
    bg:connect_signal("mouse::leave", function() bg.fg = C.subtext end)
    bg:buttons(gears.table.join(awful.button({}, 1, function() onclick(t) end)))
    return bg
end

local dnd = header_btn("󰂛 DND: off", function(t)
    naughty.suspended = not naughty.suspended
    t.text = "󰂛 DND: " .. (naughty.suspended and "on" or "off")
end)
local clear = header_btn("󰎟 Clear", function()
    items = {}; offset = 0; render()
end)

render()

return wibox.widget {
    {
        {
            {
                {
                    markup = "<span foreground='" .. C.text .. "'>Notifications</span>",
                    font = FONT .. " SemiBold 13", widget = wibox.widget.textbox,
                },
                nil,
                { dnd, clear, spacing = dpi(12), layout = wibox.layout.fixed.horizontal },
                layout = wibox.layout.align.horizontal,
            },
            {
                widget = wibox.container.margin,
                top = -3,
                count_lbl,
            },
            list,
            spacing = dpi(8), layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(15), widget = wibox.container.margin,
    },
    bg = C.base, fg = C.text,
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(12)) end,
    widget = wibox.container.background,
    forced_height = 270,
}
