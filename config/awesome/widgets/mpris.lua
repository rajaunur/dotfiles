local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi

local function trunc(s, n)
    if utf8.len(s or "") and utf8.len(s) > n then
        return s:sub(1, utf8.offset(s, n + 1) - 1) .. "…"
    end
    return s
end

local cairo = require("lgi").cairo

local function cover(img, size, zoom)
    if not img then return nil end
    local surf = gears.surface(img)
    local w, h = gears.surface.get_size(surf)
    if not w or w == 0 or h == 0 then return img end

    size      = math.floor(size)
    local out = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
    local cr  = cairo.Context(out)
    local s   = math.max(size / w, size / h) * (zoom or 1)

    cr:translate((size - w * s) / 2, (size - h * s) / 2)
    cr:scale(s, s)
    cr:set_source_surface(surf, 0, 0)
    cr:paint()
    return out
end

local ART_SIZE = dpi(170)


local function col(key, fallback) return beautiful[key] or fallback end

local C           = {
    base     = col("base", "#1e1e2e"),
    surface0 = col("surface0", "#313244"),
    surface1 = col("surface1", "#45475a"),
    overlay  = col("overlay1", "#6c7086"),
    text     = col("text", "#cdd6f4"),
    subtext  = col("subtext1", "#a6adc8"),
    mauve    = col("mauve", "#cba6f7"),
    green    = col("green", "#a6e3a1"),
}
local FONT        = "JetBrainsMono Nerd Font"
local SEP         = "|||"

local ICON        = {
    prev  = utf8.char(0xF04AE),
    next  = utf8.char(0xF04AD),
    play  = utf8.char(0xF040A),
    pause = utf8.char(0xF03E4),
}
local PLAYER_ICON = {
    spotify  = utf8.char(0xF04C7),
    spotifyd = utf8.char(0xF04C7),
    firefox  = utf8.char(0xF0239),
    chromium = utf8.char(0xF02AF),
    chrome   = utf8.char(0xF02AF),
}

local state       = { status = "Stopped", length = 0, position = 0, art = "" }

-- ---------- helpers ----------
local function split(s, sep)
    local out, i = {}, 1
    while true do
        local a, b = s:find(sep, i, true)
        if not a then
            out[#out + 1] = s:sub(i); break
        end
        out[#out + 1] = s:sub(i, a - 1)
        i = b + 1
    end
    return out
end

local function esc(s) return gears.string.xml_escape(s or "") end

local function fmt_time(sec)
    sec = math.max(0, math.floor(sec or 0))
    return string.format("%d:%02d", sec // 60, sec % 60)
end

-- ---------- widgets ----------
local art = wibox.widget {
    image = nil,
    resize = true,
    upscale = true,
    widget = wibox.widget.imagebox,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, dpi(8))
    end,
    shape_clip = true,
}
local art_box = wibox.widget {
    {
        art,
        { -- placeholder kalau tidak ada cover
            id = "ph", text = "♪", align = "center", valign = "center",

            font = FONT .. " 24", widget = wibox.widget.textbox,
        },
        layout = wibox.layout.stack,
        forced_height = dpi(170),
        forced_width = dpi(170),
    },
    bg = C.surface0, fg = C.overlay,
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(8)) end,
    shape_clip = true,
    widget = wibox.container.background,
}

local title = wibox.widget {
    forced_height = 50,
    markup = "", font = FONT .. " SemiBold 13", ellipsize = "end",
    widget = wibox.widget.textbox,
    valign = "top",
}

local album_lbl = wibox.widget {
    forced_height = 20,
    markup = "", font = FONT .. " 11", ellipsize = "end",
    widget = wibox.widget.textbox,
}

local artist = wibox.widget {
    forced_height = 20,
    markup = "", font = FONT .. " 10", ellipsize = "end",
    widget = wibox.widget.textbox,
}
local player_lbl = wibox.widget {
    text = "", font = FONT .. " 10", align = "right",
    widget = wibox.widget.textbox,
}
local time_lbl = wibox.widget {
    text = "0:00 / 0:00", font = FONT .. " 10", widget = wibox.widget.textbox,
}
local bar = wibox.widget {
    max_value = 1, value = 0, forced_height = dpi(6),
    background_color = C.surface1, color = C.mauve,
    shape = gears.shape.rounded_bar, bar_shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar,
}

local function make_btn(text, onclick, size)
    local w = wibox.widget {
        text = text, font = FONT .. " " .. (size or 19), align = "center",
        widget = wibox.widget.textbox,
    }
    local bg = wibox.widget { w, fg = C.text, widget = wibox.container.background }
    bg:connect_signal("mouse::enter", function() bg.fg = C.mauve end)
    bg:connect_signal("mouse::leave", function() bg.fg = C.text end)
    bg:buttons(gears.table.join(awful.button({}, 1, onclick)))
    return bg, w
end

local btn_prev = make_btn(ICON.prev, function() awful.spawn({ "playerctl", "previous" }) end)
local btn_play, play_txt = make_btn(ICON.play, function() awful.spawn({ "playerctl", "play-pause" }) end, 20)
local btn_next = make_btn(ICON.next, function() awful.spawn({ "playerctl", "next" }) end)

-- klik progress bar = seek
bar:buttons(gears.table.join(awful.button({}, 1, function(_, lx, _, _, _, res)
    if state.length > 0 and res and res.width and res.width > 0 then
        local target = state.length * math.min(1, math.max(0, lx / res.width))
        awful.spawn({ "playerctl", "position", string.format("%.2f", target) })
        state.position = target
    end
end)))

-- klik label player = ganti ke player lain (kiri: next, kanan: sebelumnya)
player_lbl:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn({ "playerctld", "shift" }) end),
    awful.button({}, 3, function() awful.spawn({ "playerctld", "unshift" }) end)
))

local function limit(w, width)
    return wibox.widget {
        w, strategy = "max", width = width, widget = wibox.container.constraint,
    }
end

local widget = wibox.widget {
    {
        art_box,
        {
            {
                limit(title, dpi(230)),
                limit(album_lbl, dpi(230)),
                limit(artist, dpi(230)),
                spacing = dpi(2), layout = wibox.layout.fixed.vertical,
            },
            { bar, top = dpi(8), bottom = dpi(2), widget = wibox.container.margin },
            {
                time_lbl,
                nil,
                {
                    btn_prev, btn_play, btn_next,
                    spacing = dpi(15), layout = wibox.layout.fixed.horizontal,
                },
                layout = wibox.layout.align.horizontal,
                expand = "inside",
            },
            player_lbl,
            spacing = dpi(2), layout = wibox.layout.fixed.vertical,
        },
        spacing = dpi(12), layout = wibox.layout.fixed.horizontal,
    },
    margins = dpi(15), widget = wibox.container.margin,
}

local root = wibox.widget {
    widget, bg = C.base, fg = C.text,
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(12)) end,
    forced_height = 200,
    widget = wibox.container.background,
}

-- ---------- update ui ----------
local function refresh_progress()
    if state.length > 0 then
        bar.value = math.min(1, state.position / state.length)
        time_lbl.text = fmt_time(state.position) .. " / " .. fmt_time(state.length)
    else
        bar.value = 0
        time_lbl.text = state.status == "Stopped" and "" or "live"
    end
end

local function set_idle()
    state.status, state.length, state.position, state.art = "Stopped", 0, 0, ""
    title.markup                                          = "<span foreground='" ..
        C.overlay .. "'>No music played</span>"
    artist.markup                                         = ""
    album_lbl.text                                        = ""
    player_lbl.text                                       = ""
    art.image                                             = nil
    play_txt.text                                         = ICON.play
    refresh_progress()
end

local function set_art(url)
    if url == state.art then return end
    state.art = url
    art.image = nil
    if url == "" then return end

    local function apply(path)
        local zoom = url:match("ytimg%.com") and 1.34 or 1 -- buang bar hitam hqdefault
        art.image = cover(gears.surface.load_uncached(path), ART_SIZE, zoom)
    end

    if url:match("^file://") then
        apply((url:gsub("^file://", "")))
    elseif url:match("^https?://") then
        local file = "/tmp/awm_mpris_" .. url:gsub("[^%w]", ""):sub(-40)
        local function load()
            if state.art == url and gears.filesystem.file_readable(file) then
                apply(file)
            end
        end
        if gears.filesystem.file_readable(file) then
            load()
        else
            awful.spawn.easy_async({ "curl", "-sL", "--max-time", "8", "-o", file, url }, load)
        end
    end
end

local function on_line(line)
    if line == "" then return set_idle() end
    local f                                        = split(line, SEP)
    local status, player, a, t, alb, url, pos, len =
        f[1], f[2], f[3], f[4], f[5], f[6], tonumber(f[7]), tonumber(f[8])

    state.status                                   = status ~= "" and status or "Stopped"
    state.length                                   = (len or 0) / 1e6
    state.position                                 = (pos or 0) / 1e6

    title.markup                                   = "<span foreground='" ..
        C.text .. "'>" .. esc(trunc(t ~= "" and t or "Unknown", 40)) .. "</span>"

    artist.markup                                  = "<span foreground='" .. C.subtext .. "'>" .. esc(a) .. "</span>"
    album_lbl.markup                               = "<span foreground='" ..
        C.subtext .. "'>" .. esc(trunc(alb, 20)) .. "</span>"

    local name                                     = (player or ""):gsub("%.instance.*", "")
    player_lbl.markup                              = "<span foreground='" .. C.overlay .. "'>"
        .. (PLAYER_ICON[name:lower()] or "♪") .. " " .. esc(name) .. "</span>"

    play_txt.text                                  = state.status == "Playing" and ICON.pause or ICON.play
    set_art(url or "")
    refresh_progress()
end

-- ---------- listener (event-based) ----------
local FORMAT = table.concat({
    "{{status}}", "{{playerName}}", "{{artist}}", "{{title}}", "{{album}}",
    "{{mpris:artUrl}}", "{{position}}", "{{mpris:length}}",
}, SEP)

local follow_pid
local function start_follow()
    follow_pid = awful.spawn.with_line_callback(
        { "playerctl", "--follow", "metadata", "--format", FORMAT },
        {
            stdout = on_line,
            exit = function()
                gears.timer.start_new(2, function()
                    start_follow()
                    return false
                end)
            end,
        }
    )
end

awful.spawn.with_shell("pkill -f 'playerctl --follow metadata' ; true")
set_idle()
start_follow()
awesome.connect_signal("exit", function()
    if type(follow_pid) == "number" then awful.spawn({ "kill", tostring(follow_pid) }) end
end)

-- ---------- poll ringan: status + posisi (1 detik) ----------
gears.timer {
    timeout = 1, autostart = true,
    callback = function()
        awful.spawn.easy_async_with_shell("playerctl status && playerctl position",
            function(out, _, _, code)
                if code ~= 0 then
                    if state.status ~= "Stopped" or state.art ~= "" then set_idle() end
                    return
                end
                local s, p = out:match("^(%S+)%s+([%d%.]+)")
                if s then
                    state.status   = s
                    state.position = tonumber(p) or state.position
                    play_txt.text  = s == "Playing" and ICON.pause or ICON.play
                    refresh_progress()
                end
            end)
    end,
}

return root
