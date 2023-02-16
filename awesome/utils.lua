local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local awful = require "awful"

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




-- FROM REDDIT | https://www.reddit.com/r/awesomewm/comments/t47dkn/comment/hyxmucu/
local function click_to_hide(widget, hide_fct, only_outside)
    only_outside = only_outside or false

    hide_fct = hide_fct or function(object)
        if only_outside and object == widget then
            return
        end
        widget.visible = false
    end

    local click_bind = awful.button({ }, 1, hide_fct)

    local function manage_signals(w)
        if not w.visible then
            wibox.disconnect_signal("button::press", hide_fct)
            client.disconnect_signal("button::press", hide_fct)
            awful.mouse.remove_global_mousebinding(click_bind)
        else
            awful.mouse.append_global_mousebinding(click_bind)
            client.connect_signal("button::press", hide_fct)
            wibox.connect_signal("button::press", hide_fct)
        end
    end

    -- when the widget is visible, we hide it on button press
    widget:connect_signal('property::visible', manage_signals)

    function widget.disconnect_click_to_hide()
        widget:disconnect_signal('property::visible', manage_signals)
    end

end

local function click_to_hide_menu(menu, hide_fct, outside_only)
    hide_fct = hide_fct or function()
        menu:hide()
    end

    click_to_hide(menu.wibox, hide_fct, outside_only)
end


util.menu = click_to_hide_menu
util.popup = click_to_hide





return util

 