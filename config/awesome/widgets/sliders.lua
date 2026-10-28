local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local M = {}

local function clamp(v) return math.max(0, math.min(100, v)) end

local function make_bar(w, h, color, bg)
    local bar = wibox.widget.base.make_widget()
    bar._value, bar._color = 0, color

    function bar:fit(_, _, _) return w, h end

    function bar:draw(_, cr, width, height)
        gears.shape.rounded_bar(cr, width, height)
        cr:set_source(gears.color(bg))
        cr:fill()
        local fill_h = height * self._value / 100
        if fill_h > 0 then
            cr:save()
            gears.shape.rounded_bar(cr, width, height)
            cr:clip()
            cr:rectangle(0, height - fill_h, width, fill_h)
            cr:set_source(gears.color(self._color))
            cr:fill()
            cr:restore()
        end
    end

    function bar:set_state(value, color)
        self._value = clamp(value)
        if color then self._color = color end
        self:emit_signal("widget::redraw_needed")
    end

    return bar
end

local function make_slider(args)
    local icon = wibox.widget {
        text   = args.icon,
        font   = ("JetBrainsMono Nerd Font " .. (args.icon_size or "20")),
        align  = "center",
        widget = wibox.widget.textbox,
    }

    local label = wibox.widget {
        text   = "0%",
        font   = "JetBrainsMono Nerd Font 13",
        align  = "center",
        widget = wibox.widget.textbox,
    }

    local bar = make_bar(8, args.height or 120, args.color, beautiful.surface0)

    -- Area klik lebih lebar dari bar supaya gampang diklik
    local bar_area = wibox.widget {
        bar,
        left = 14, right = 14,
        widget = wibox.container.margin,
    }

    local root = wibox.widget {
        {
            widget = wibox.container.margin,
            bottom = 5,
        },
        bar_area,
        {
            widget = wibox.container.margin,
            left = args.icon_margin_left or 0,
            top = args.icon_margin_top or 2,
            icon,
        },
        spacing      = 6,
        forced_width = 40, -- kunci lebar, supaya tidak melar
        layout       = wibox.layout.fixed.vertical,
    }

    local function set_display(value, muted)
        value = clamp(value)
        label.text = string.format("%d", value)
        bar:set_state(value, muted and beautiful.red or args.color)
        if args.icon_fn then icon.text = args.icon_fn(value, muted) end
    end

    bar_area:connect_signal("button::press", function(_, _, ly, button, _, res)
        if button == 1 then
            -- ly = 0 di atas, dibalik: bawah = 0%, atas = 100%
            local pct = math.floor(clamp((1 - ly / res.height) * 100) + 0.5)
            args.set(pct)
            set_display(pct, false)
        elseif button == 4 then
            args.step(5)
        elseif button == 5 then
            args.step(-5)
        end
    end)

    if args.on_icon_click then
        icon:connect_signal("button::press", function(_, _, _, button)
            if button == 1 then args.on_icon_click() end
        end)
    end

    return root, set_display
end

---------------------------------------------------------------- VOLUME
function M.volume(height)
    local widget, set_display
    local function update()
        awful.spawn.easy_async_with_shell(
            "wpctl get-volume @DEFAULT_AUDIO_SINK@", function(out)
                local v = tonumber(out:match("([%d%.]+)")) or 0
                set_display(math.floor(v * 100 + 0.5), out:find("MUTED") ~= nil)
            end)
    end

    widget, set_display = make_slider {
        height          = height,
        color           = beautiful.blue,
        icon            = "󰕾",
        icon_size       = 18,
        icon_margin_top = 20,
        icon_fn         = function(v, muted)
            if muted or v == 0 then
                return "󰖁"
            elseif v < 50 then
                return "󰖀"
            else
                return "󰕾"
            end
        end,
        set             = function(p)
            awful.spawn.with_shell(
                string.format("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ %d%%", p))
        end,
        step            = function(d)
            local sign = d > 0 and "+" or "-"
            awful.spawn.easy_async_with_shell(
                string.format("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ %d%%%s", math.abs(d), sign),
                update)
        end,
        on_icon_click   = function()
            awful.spawn.easy_async_with_shell(
                "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", update)
        end,
    }

    gears.timer { timeout = 0.5, autostart = true, call_now = true, callback = update }
    return widget, update
end

------------------------------------------------------------- BRIGHTNESS
function M.brightness(height)
    local widget, set_display
    local function update()
        awful.spawn.easy_async_with_shell(
            "echo $(( $(brightnessctl g) * 100 / $(brightnessctl m) ))", function(out)
                set_display(tonumber(out) or 0, false)
            end)
    end

    widget, set_display = make_slider {
        height           = height,
        color            = beautiful.peach,
        icon             = "󰃟",
        icon_margin_left = -8,
        icon_margin_top  = 20,
        icon_size        = 15,
        set              = function(p)
            awful.spawn.with_shell(string.format("brightnessctl set %d%%", math.max(p, 1)))
        end,
        step             = function(d)
            local sign = d > 0 and "+" or "-"
            awful.spawn.easy_async_with_shell(
                string.format("brightnessctl set %d%%%s", math.abs(d), sign), update)
        end,
    }

    gears.timer { timeout = 0.5, autostart = true, call_now = true, callback = update }
    return widget, update
end

return M
