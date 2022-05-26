local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

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
return util