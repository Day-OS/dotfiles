local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local separators = { height = 0, width = 9 }

local dir = {LEFT = false, RIGHT = true}
local ty = {ARROW = "arrow", TRAPEZIUM = "trapezium"}

local sep = {
    --Modified code from lain
    direction = dir,
    type = ty,
    new = function (col1, col2, direction, type)
        type = type or ty.ARROW
        local widget = wibox.widget.base.make_widget()
        widget.col1 = col1
        widget.col2 = col2
    
        widget.fit = function(_, _, _)
            return separators.width, separators.height
        end
    
        widget.update = function(c1, c2)
            widget.col1 = direction and c1 or col1
            widget.col2 = direction and c2 or col2
            widget:emit_signal("widget::redraw_needed")
        end
    
        widget.draw = function(_, _, cr, width, height)
            if widget.col2 ~= "alpha" then
                cr:set_source_rgba(gears.color.parse_color(widget.col2))
                cr:new_path()
                cr:move_to(direction and 0 or width, 0)
                cr:line_to(direction and width or 0, height/(type == ty.ARROW and 2 or 1))
                cr:line_to(direction and width or 0, 0)
                cr:close_path()
                cr:fill()
    
                cr:new_path()
                cr:move_to(direction and 0 or width, height)
                cr:line_to(direction and width or 0, height/(type == ty.ARROW and 2 or 1))
                cr:line_to(direction and width or 0, height)
                cr:close_path()
                cr:fill()
            end
    
            if widget.col1 ~= "alpha" then
                cr:set_source_rgba(gears.color.parse_color(widget.col1))
                cr:new_path()
                cr:move_to(direction and 0 or width, 0)
                cr:line_to(direction and width or 0, height/(type == ty.ARROW and 2 or 1))
                cr:line_to(direction and 0 or width, height)
                cr:close_path()
                cr:fill()
            end
       end
    
       return widget
    end    
}
return sep