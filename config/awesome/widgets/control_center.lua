local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")


local weather = require("widgets.weather")
local sliders = require("widgets.sliders")
local vol_slider, vol_update = sliders.volume(170)
local bri_slider, bri_update = sliders.brightness(170)
local mpris = require('widgets.mpris')
local notification = require('widgets.notification')



function get_aggregate_battery()
    -- Menjalankan perintah acpi dan menghitung rata-rata persentasenya
    local cmd =
    "acpi -b 2>/dev/null | awk -F, '{sum+=$2; count++} END {if(count>0) print int(sum/count); else print 0}'"
    local handle = io.popen(cmd)

    if handle then
        local result = handle:read("*a")
        handle:close()

        -- Bersihkan spasi/karakter newline di akhir string
        local battery_percentage = result:gsub("%s+", "")

        -- Mengembalikan persentase dalam bentuk angka (number)
        return tonumber(battery_percentage) or 0
    end
    return 0
end

function get_ram_usage()
    local file = io.open("/proc/meminfo", "r")
    if not file then return 0 end

    local mem_total, mem_available = 0, 0

    for line in file:lines() do
        -- Ambil total kapasitas RAM fisik
        if line:match("^MemTotal:") then
            mem_total = tonumber(line:match("(%d+)"))
            -- Ambil RAM yang benar-benar tersedia (akurat, sudah memperhitungkan cache/buffers)
        elseif line:match("^MemAvailable:") then
            mem_available = tonumber(line:match("(%d+)"))
        end

        -- Berhenti membaca jika kedua data sudah didapatkan
        if mem_total > 0 and mem_available > 0 then break end
    end
    file:close()

    if mem_total > 0 then
        -- Hitung RAM yang terpakai
        local mem_used = mem_total - mem_available
        -- Hitung persentase penggunaan RAM
        local percentage = math.floor((mem_used / mem_total) * 100)
        return percentage
    end

    return 0
end

function getUptime()
    local file = io.open("/proc/uptime", "r")
    if not file then
        return "N/A"
    end

    local uptime = file:read("*n")
    file:close()

    local days = math.floor(uptime / 86400)
    local hours = math.floor((uptime % 86400) / 3600)
    local minutes = math.floor((uptime % 3600) / 60)

    if days > 0 then
        return string.format("%dd %02dh %02dm", days, hours, minutes)
    end

    return string.format("%02dh %02dm", hours, minutes)
end

function make_arc(value, icon, label, color)
    return {
        widget = wibox.container.arcchart,
        min_value = 0,
        max_value = 100,
        forced_height = 120,
        value = value,
        thickness = 8,
        rounded_edge = true,
        colors = { color },
        bg = beautiful.surface0 or "#313244",
        paddings = 6,
        {
            {
                layout = wibox.layout.fixed.vertical,
                spacing = 2,
                {
                    widget = wibox.container.margin,
                    left = 2,
                    {
                        forced_width = 30,
                        widget = wibox.widget.textbox,
                        markup = '<span font="JetBrainsMono Nerd Font 20">' .. "" .. icon .. '</span>',
                    }
                },
                {
                    widget = wibox.widget.textbox,
                    align = "center",
                    markup = '<span font="JetBrainsMono Nerd Font 14"><b>' .. label .. '</b></span>',
                },
            },
            align = "center",
            valign = "center",
            widget = wibox.container.place,
        },
    }
end

local first_grid = wibox.widget {
    homogeneous   = false,
    spacing       = 15,
    min_cols_size = 10,
    min_rows_size = 10,
    layout        = wibox.layout.grid,
}

local second_grid = wibox.widget {
    homogeneous   = false,
    spacing       = 15,
    min_cols_size = 10,
    min_rows_size = 10,
    layout        = wibox.layout.grid,
}


local welcome_text = wibox.widget {
    layout = wibox.container.background,
    forced_width = 240,
    forced_height = 160,
    bg = beautiful.base,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end,
    {
        layout = wibox.container.margin,
        margins = 20,
        {
            layout = wibox.layout.fixed.vertical,
            -- welcome text
            {
                layout = wibox.layout.fixed.vertical,
                spacing = -3,
                {
                    widget = wibox.widget.textbox,
                    markup = '<span font="JetBrainsMono Nerd Font 14">welcome</span>'
                },
                {
                    widget = wibox.widget.background,
                    fg = beautiful.blue,
                    {
                        widget = wibox.widget.textbox,
                        markup = '<span font="JetBrainsMono Nerd Font 21"><b>' .. os.getenv("USER") .. '</b></span>'
                    },
                },
                {
                    widget = wibox.widget.textbox,
                    markup = '<span font="JetBrainsMono Nerd Font 12">have a nice day!</span>'
                },
            },
            -- {
            --     widget = wibox.widget.imagebox,
            --     image = gears.filesystem.get_configuration_dir() .. 'assets/fih.png',
            --     forced_height = 120,
            --     forced_width = 120
            -- }
        }
    }
}


local current_day = wibox.widget {
    layout = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end,
    forced_width = 200,
    bg = beautiful.base,
    {
        layout = wibox.container.margin,
        margins = 15,
        {
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.background,
                fg = beautiful.subtext1,
                {
                    markup = '<span font="JetBrainsMono Nerd Font 13" foreground="' .. beautiful.pink .. '">' .. os.date("%A") .. '</span>',
                    widget = wibox.widget.textbox
                },
            },
            {
                markup = '<span font="JetBrainsMono Nerd Font SemiBold 17">' .. os.date("%B %d") .. '</span>',
                widget = wibox.widget.textbox
            }
        }
    }
}

local uptime = wibox.widget {
    layout = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end,
    forced_width = 200,
    forced_height = 100,
    bg = beautiful.base,
    {
        layout = wibox.container.margin,
        margins = 15,
        {
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.margin,
                bottom = 1,
                {
                    markup = '<span font="JetBrainsMono Nerd Font 20">󰔛</span>',
                    widget = wibox.widget.textbox
                },
            },
            {
                layout = wibox.container.background,
                fg = beautiful.blue,
                {
                    markup = '<span font="JetBrainsMono Nerd Font 13">Uptime</span>',
                    widget = wibox.widget.textbox
                },
            },
            {
                markup = '<span font="JetBrainsMono Nerd Font SemiBold 17">' .. getUptime() .. '</span>',
                widget = wibox.widget.textbox
            }
        }
    }
}




local ram = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.base,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    {
        widget = wibox.container.margin,
        margins = 15,
        {
            layout = wibox.layout.fixed.vertical,
            spacing = 15,
            {
                layout = wibox.layout.fixed.horizontal,
                {
                    widget = wibox.widget.textbox,
                    text = "",
                    font = "JetBrainsMono Nerd Font 20",
                    forced_width = 30,
                },
                {
                    widget = wibox.container.margin,
                    left = 8,
                    {
                        widget = wibox.widget.textbox,
                        text = get_ram_usage() .. '%',
                        font = "JetBrainsMono Nerd Font 16",
                    }
                }


            },
            {
                widget = wibox.container.margin,
                top = -10,
                {
                    widget = wibox.widget.textbox,
                    markup = "<span font='JetBrainsMono Nerd Font 13' foreground='" .. beautiful.subtext1 .. "'>RAM Used</span>",
                }
            }
        }
    }
}

local battery = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.base,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    {
        widget = wibox.container.margin,
        margins = 15,
        {
            layout = wibox.layout.fixed.vertical,
            spacing = 15,
            {
                layout = wibox.layout.fixed.horizontal,
                {
                    widget = wibox.widget.textbox,
                    text = "",
                    font = "JetBrainsMono Nerd Font 20",
                    forced_width = 30,
                },
                {
                    widget = wibox.container.margin,
                    left = 8,
                    {
                        widget = wibox.widget.textbox,
                        text = get_aggregate_battery() .. '%',
                        font = "JetBrainsMono Nerd Font 16",
                    }
                }


            },
            {
                widget = wibox.container.margin,
                top = -10,
                {
                    widget = wibox.widget.textbox,
                    markup = "<span font='JetBrainsMono Nerd Font 13' foreground='" .. beautiful.subtext1 .. "'>Battery</span>",

                }
            }
        }
    }
}

local stats_control = wibox.widget {
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end,
    widget = wibox.container.background,
    bg = beautiful.base,
    forced_width = 150,
    forced_height = 110,
    {
        widget = wibox.container.margin,
        top = 30,
        bottom = 35,
        right = 15,
        left = 37,
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 30,
            {
                widget = wibox.container.margin,
                bri_slider
            },
            {
                widget = wibox.container.margin,
                vol_slider
            }
        }
    }
}

local hw_stats = wibox.widget {
    forced_height = 100,
    layout = wibox.layout.flex.horizontal,
    spacing = 15,
    battery, ram,
}

local music_control = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.base,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end,
    mpris
}

first_grid:add_widget_at(welcome_text, 1, 1, 3, 3)
first_grid:add_widget_at(current_day, 1, 4, 1, 2)
first_grid:add_widget_at(uptime, 2, 4, 2, 2)
second_grid:add_widget_at(weather, 1, 1, 1, 2)
second_grid:add_widget_at(hw_stats, 2, 1, 1, 2)
second_grid:add_widget_at(stats_control, 1, 3, 2, 4)

-- Control Panel
local cc = awful.popup {
    widget = {
        {
            layout = wibox.layout.fixed.vertical,
            spacing = 15,
            first_grid,
            second_grid,
            music_control,
            notification
        },
        margins = 15,
        forced_width = 500,
        forced_height = 1050,
        widget = wibox.container.margin,
    },
    bg = beautiful.mantle,
    placement = function(c)
        awful.placement.top_left(c, { margins = { top = 15, left = 80 } })
    end,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 10)
    end,
    ontop = true,
    visible = false

}

return cc
