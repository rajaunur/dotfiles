local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

local latitude = -6.9389
local longitude = 109.1171

local weather = wibox.widget {
    {

        {
            {
                layout = wibox.layout.fixed.vertical,
                {
                    layout = wibox.container.background,
                    fg = beautiful.teal,
                    {

                        layout = wibox.layout.fixed.horizontal,
                        {
                            widget = wibox.container.margin,
                            left = -10,
                            {
                                forced_width = 50,
                                id = "icon",
                                text = "󰖐",
                                font = "JetBrainsMono Nerd Font 30",
                                align = "center",
                                widget = wibox.widget.textbox,
                            },
                        },
                        {
                            widget = wibox.container.margin,
                            left = 10,
                            {
                                id = "temp",
                                text = "--°C",
                                font = "JetBrainsMono Nerd Font 16",
                                widget = wibox.widget.textbox,
                            },
                        }
                    }
                },
                {
                    widget = wibox.container.margin,
                    top = 10,
                    {
                        {
                            markup = "<span>Tegal</span>",
                            font = "JetBrainsMono Nerd Font SemiBold 16",
                            widget = wibox.widget.textbox,
                        },
                        {
                            widget = wibox.container.background,
                            fg = beautiful.subtext1,
                            {
                                id = "condition",
                                text = "Loading...",
                                font = "JetBrainsMono Nerd Font 13",
                                widget = wibox.widget.textbox,
                            },
                        },
                        {
                            widget = wibox.container.margin,
                            top = -5,
                            {
                                id = "humidity",
                                text = "Humidity: --%",
                                font = "JetBrainsMono Nerd Font 12",
                                widget = wibox.widget.textbox,
                            },
                        },
                        spacing = 4,
                        layout = wibox.layout.fixed.vertical,
                    },

                }
            },
            spacing = 15,
            layout = wibox.layout.fixed.horizontal,
        },
        margins = 15,
        widget = wibox.container.margin,
    },
    bg = beautiful.base,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end,
    layout = wibox.container.background,
    forced_width = 255,
    forced_height = 180
}

local icons = {
    [0] = "󰖙", -- Clear sky
    [1] = "󰖕", -- Mainly clear
    [2] = "󰖕", -- Partly cloudy
    [3] = "󰖐", -- Overcast
    [45] = "󰖑", -- Fog
    [48] = "󰖑",
    [51] = "󰖗", -- Drizzle
    [53] = "󰖗",
    [55] = "󰖗",
    [61] = "󰖗", -- Rain
    [63] = "󰖗",
    [65] = "󰖗",
    [71] = "󰖘", -- Snow
    [73] = "󰖘",
    [75] = "󰖘",
    [80] = "󰖗", -- Showers
    [81] = "󰖗",
    [82] = "󰖗",
    [95] = "󰖓", -- Thunderstorm
    [96] = "󰖓",
    [99] = "󰖓",
}

local conditions = {
    [0] = "Clear sky",
    [1] = "Mostly clear",
    [2] = "Partly cloudy",
    [3] = "Overcast",
    [45] = "Fog",
    [48] = "Rime fog",
    [51] = "Light drizzle",
    [53] = "Drizzle",
    [55] = "Heavy drizzle",
    [61] = "Light rain",
    [63] = "Moderate rain",
    [65] = "Heavy rain",
    [71] = "Light snow",
    [73] = "Snow",
    [75] = "Heavy snow",
    [80] = "Rain showers",
    [81] = "Rain showers",
    [82] = "Heavy showers",
    [95] = "Thunderstorm",
    [96] = "Thunderstorm",
    [99] = "Heavy thunderstorm",
}

local function updateWeather()
    local url = string.format(
        "https://api.open-meteo.com/v1/forecast"
        .. "?latitude=%s&longitude=%s"
        .. "&current=temperature_2m,relative_humidity_2m,weather_code"
        .. "&timezone=auto",
        latitude,
        longitude
    )

    awful.spawn.easy_async_with_shell(
        "curl -fsS --max-time 10 " .. "'" .. url .. "'",
        function(stdout, _, _, exit_code)
            if exit_code ~= 0 then
                weather:get_children_by_id("condition")[1].text =
                "Weather unavailable"
                return
            end

            local temp = stdout:match(
                '"temperature_2m":([%d%.%-]+)'
            )
            local humidity = stdout:match(
                '"relative_humidity_2m":(%d+)'
            )
            local code = stdout:match(
                '"weather_code":(%d+)'
            )

            if not temp or not humidity or not code then
                weather:get_children_by_id("condition")[1].text =
                "Invalid response"
                return
            end

            code = tonumber(code)

            weather:get_children_by_id("temp")[1].text =
                math.floor(tonumber(temp) + 0.5) .. "°C"

            weather:get_children_by_id("humidity")[1].text =
                "Humidity: " .. humidity .. "%"

            weather:get_children_by_id("condition")[1].text =
                conditions[code] or "Unknown"

            weather:get_children_by_id("icon")[1].text =
                icons[code] or "󰖐"
        end
    )
end

updateWeather()

gears.timer {
    timeout = 600,
    autostart = true,
    call_now = false,
    callback = updateWeather,
}

return weather
