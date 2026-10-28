local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modkey = "Mod4"

local function col(name, default) return beautiful[name] or default end

local state_icons = {
    empty    = "󰧞",
    occupied = "",
    selected = "󰮯",
    urgent   = "",
}

local buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Atur tampilan satu tag sesuai statusnya
local function apply_state(self, t)
    local bg    = self:get_children_by_id("bg")[1]
    local label = self:get_children_by_id("label")[1]

    local bg_color, fg_color, icon
    if t.urgent then
        bg_color, fg_color, icon = col("red", "#f38ba8"), col("base", "#1e1e2e"), state_icons.urgent
    elseif t.selected then
        bg_color, fg_color, icon = col("blue", "#89b4fa"), col("yellow", "#1e1e2e"), state_icons.selected
    elseif #t:clients() > 0 then
        bg_color, fg_color, icon = col("surface", "#313244"), col("text", "#cdd6f4"), state_icons.occupied
    else
        bg_color, fg_color, icon = "#00000000", col("overlay", "#6c7086"), state_icons.empty
    end
    label.markup = string.format('<span foreground="%s">%s</span>', fg_color, icon)
end

return function(s)
    local taglist = awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        buttons         = buttons,
        layout          = {
            spacing = 6,
            layout  = wibox.layout.fixed.vertical,
        },
        widget_template = {
            {
                {
                    id     = "label",
                    align  = "center",
                    valign = "center",
                    font   = "JetBrainsMono Nerd Font 15",
                    widget = wibox.widget.textbox,
                },
                id            = "bg",
                forced_width  = 32,
                forced_height = 32,
                shape         = gears.shape.rounded_bar,
                widget        = wibox.container.background,
            },
            widget          = wibox.container.margin,
            create_callback = function(self, t) apply_state(self, t) end,
            update_callback = function(self, t) apply_state(self, t) end,
        },
    }

    return wibox.widget {
        {
            taglist,
            top    = 10,
            left   = 6,
            right  = 6,
            bottom = 10,
            widget = wibox.container.margin,
        },
        bg     = col("base", "#1e1e2e"),
        shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, h / 2) end,
        widget = wibox.container.background,
    }
end
