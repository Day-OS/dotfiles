local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local util = {
    changewidgetbg = function(wi, color)
        return wibox.container.background(wi, color)
    end,

    createicon = function (icon, color, font, size)
        icon = icon or "\u{f2fd}"
        size = size or beautiful.icon_size
        color = color or beautiful.bg_normal
        font = font or beautiful.icon_font
        local iconwidget = wibox.widget{
            markup = ' <span color="'.. color ..'">'.. icon ..'</span> ',
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
        }
        iconwidget.font = font .. size
        return iconwidget
    end,
}
util.maximizebutton = function (cr)
    local maximizebutton = util.changewidgetbg(util.createicon('\u{f31e}', beautiful.bg_focus), beautiful.color_array[1])
    maximizebutton:connect_signal("button::press", function(c, _, _, button)
        if button == 1 then
            cr.maximized = not cr.maximized
        end
    end)
    return maximizebutton
end
util.close = function (cr)
    local maximizebutton = util.changewidgetbg(util.createicon('\u{f54c}', beautiful.bg_focus), beautiful.color_array[1])
    maximizebutton:connect_signal("button::press", function(c, _, _, button)
        if button == 1 then
            cr:kill()
        end
    end)
    return maximizebutton
end



return util

 