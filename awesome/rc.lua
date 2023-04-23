pcall(require, "luarocks.loader")
local cairo = require("lgi").cairo
local gears = require("gears")
local awful = require("awful")
awful.spawn("wal -R")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
naughty.config.defaults['icon_size'] = 100
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local lain = require("lain")
local lainseparators = lain.util.separators
local markup = lain.util.markup
local utils = require("utils")
local sep = require("separators")
local globalkeys = require("globalkeys")
local dpi = require("beautiful.xresources").apply_dpi
--local net_speed_widget = require("awesome-wm-widgets/awesome-wm-widgets.net-speed-widget.net-speed")
local mpris_widget = require("awesome-wm-widgets.mpris-widget")
local isMicHotkeyBeingPressed = false

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")


--pactl set-source-mute 1 toggle
--pactl get-source-mute 0 


awful.spawn("picom --animations")
--awful.spawn("picom-trans --experimental-backends")
awful.spawn("xmousepasteblock")
--awful.spawn.once("/usr/lib/xfce-polkit/xfce-polkit")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.corner.nw,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
   { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   --{ "manual", terminal .. " -e man awesome" },
   --{ "edit config", editor_cmd .. " " .. awesome.conffile },
   { "Restart", awesome.restart, beautiful.awesome_icon },
   { "Quit", function() awesome.quit() end, beautiful.awesome_icon },
   { "shutdown System", function() awful.spawn("shutdown") end },
}
local apps = {
    { "Firefox", function () awful.spawn("firefox") end },
    { "Discord", function () awful.spawn("discord") end },
    { "Spotify", function () awful.spawn("spotify") end },
    { "Steam", function () awful.spawn("steam") end },
    { "Bluetooth", function () awful.spawn("blueman-manager") end },
    { "Audio (Pavu)", function () awful.spawn("pavucontrol") end },
    { "NoiseTorch", function () awful.spawn("noisetorch -i") end },
}

mymainmenu = awful.menu({ items = { { "Programs", apps},
                                    { "System", myawesomemenu },
                                    { "Open Terminal", terminal }
                                  }
                        })

--utils.menu(mymainmenu, nil, true)

--mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function(c)
                                            topbar = awful.menu({ items = { 
                                                { "Maximized", function () 
                                                    utils.change_titlebar_visibility(not c.maximized, c)
                                                    c.maximized = not c.maximized end },
                                                }})
                                            topbar:show(c)
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- FontAwesome
local space = wibox.widget{
    markup = ' <span color="'.. beautiful.bg_normal ..'"></span> ',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}
local memicon = utils.createicon('\u{f538}') 
local cpuicon = utils.createicon('\u{f2db}') 
local neticon = utils.createicon('\u{f1eb}', beautiful.bg_focus)
local micONicon = '\u{f130}'
local micOFFicon = '\u{f131}'
local micIcon = awful.widget.watch("pactl get-source-mute 0", 0.5,
function(widget, stdout)
    local currentIcon
    local prefix = "Mute: "
    local result = string.gsub(string.gsub(tostring(stdout), prefix, ""), "\n", "")
    local isMuted = result == ("no")

    if isMuted then
        currentIcon = ' <span color="'.. beautiful.bg_focus ..'">'.. micONicon ..'</span> '
    else
        currentIcon = ' <span color="'.. beautiful.bg_focus ..'">'.. micOFFicon ..'</span> '
    end




    widget:set_markup(currentIcon)
end) --utils.createicon(micONicon, beautiful.bg_focus)

local arrl_ld1 = lainseparators.arrow_right("alpha", beautiful.bg_focus)
local arrl_ld2 = lainseparators.arrow_right(beautiful.bg_focus, "alpha")
local arrl_dl1 = lainseparators.arrow_left(beautiful.bg_focus, "alpha")
local arrl_dl2 = lainseparators.arrow_left("alpha", beautiful.bg_focus)




-- Calendar
beautiful.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus 10",
        fg   = beautiful.fg_normal,
        bg   = beautiful.bg_normal
    }
})

local mem = lain.widget.mem{
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, beautiful.bg_normal," " .. mem_now.used .. "MB "))
    end
}

local net = lain.widget.net{
    settings = function()
        widget:set_markup(
                          markup(beautiful.bg_minimize, " ▼ " .. string.format("%06.1f", net_now.received))
                          .. " " ..
                          markup(beautiful.fg_normal, " ▲ " .. string.format("%06.1f", net_now.sent) .. " "))
    end
}


-- CPU
local cpu = lain.widget.cpu{
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font,beautiful.bg_normal, " " .. cpu_now.usage .. "% "))
    end
}

-- Coretemp
local temp = lain.widget.temp{
    settings = function()
        widget:set_markup(markup.font(beautiful.font, " " .. coretemp_now .. "°C "))
    end
}




awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6"}, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style = {
            shape  = function(cr, w, h)gears.shape.partially_rounded_rect(cr, w, h, true, true, false, false, 45) end},
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 1,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 1,
                right = 1,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
    }
    s.mytasklist:connect_signal('mouse::enter', function (tasklist)
        
    end)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
            --s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            space,
             layout = wibox.layout.fixed.horizontal,
            --sep.new(beautiful.bg_focus, "alpha", sep.direction.RIGHT, sep.type.TRAPEZIUM),
            --sep.new("alpha", beautiful.bg_focus, sep.direction.RIGHT, sep.type.TRAPEZIUM),
            --sep.new(beautiful.bg_focus, "alpha", sep.direction.LEFT, sep.type.TRAPEZIUM),
            --sep.new("alpha", beautiful.bg_focus, sep.direction.LEFT, sep.type.TRAPEZIUM),
            arrl_dl2,
            utils.changewidgetbg(memicon, beautiful.bg_focus),
            utils.changewidgetbg(mem.widget, beautiful.bg_focus),
            arrl_dl1,
            --sep.new("alpha", beautiful.bg_focus, sep.direction.LEFT, sep.type.TRAPEZIUM),
            micIcon,
            --net_speed_widget(),
            --sep.new("alpha", beautiful.bg_focus, sep.direction.RIGHT, sep.type.TRAPEZIUM),
            --net,
            arrl_ld1,
            utils.changewidgetbg(cpuicon, beautiful.bg_focus),
            utils.changewidgetbg(cpu.widget, beautiful.bg_focus),
            arrl_ld2,
            --changewidgetbg(facpuicon, beautiful.bg_focus),
            --arrl_dl2,

            mykeyboardlayout,
            wibox.widget.systray(),
            

            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            utils.change_titlebar_visibility(not c.maximized, c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
    -- View tag only.
        awful.key({modkey},"0",
        function () 
            if not isMicHotkeyBeingPressed then
                local prefix = "Mute: "
                local result = string.gsub(string.gsub(tostring(io.popen("pactl get-source-mute 0"):read("a")), prefix, ""), "\n", "")
                local isMuted = result == ("no")

                if isMuted then
                    awful.spawn("paplay "..tostring(awesome.themes_path).."/default/microphone-muted-teamspeak.ogg")
                else
                    awful.spawn("paplay "..tostring(awesome.themes_path).."/default/microphone-activated-teamspeak.ogg")
                end
                
                awful.spawn("pactl set-source-mute 0 toggle") 
                micIcon:emit_signal("timeout")
                isMicHotkeyBeingPressed = true
            end

            
            
        end,
        function ()
            isMicHotkeyBeingPressed = false
        end,
        {description = "mute/unmute default microphone", group = "DayOS", keygroup = "numpad",}),
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                        local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                        local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
    -- Firefox Picture-in-Picture
    { rule = { instance = "Toolkit"},
      except = { class = "Navigator" },
      properties = { floating = false, above = true, maximized = false, sticky = true, titlebars_enabled = true,}
    },
    { rule = { class = "firefox" },
      properties = { screen = 1, tag = "1", maximized = true, titlebars_enabled = false} },
    { rule = { class = "discord" },
    properties = { screen = 1, tag = "2", maximized = true, titlebars_enabled = false} },
    { rule_any = { instance = { "vscodium", "code", "spotify"}
      }, properties = { maximized = true, titlebars_enabled = false }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)


-- [TITLEBAR OF WINDOW]
client.connect_signal("request::titlebars", function(c)
    local titlebarmenu = awful.menu({ items =   { 
        { "Floating", function() c.floating = not c.floating end, gears.filesystem.get_themes_dir() .. "default/titlebar/floating_normal_active.png"},
        { "Sticky", function() c.sticky = not c.sticky end, gears.filesystem.get_themes_dir() .. "default/titlebar/sticky_normal_inactive.png"},
        { "On-top", function() c.ontop = not c.ontop end, gears.filesystem.get_themes_dir() .. "default/titlebar/ontop_normal_inactive.png"},
        { "Picture in Picture", function() 
            currentmode = c.ontop
            c.ontop = not currentmode
            c.sticky = not currentmode
         end, gears.filesystem.get_themes_dir() .. "default/titlebar/ontop_normal_inactive.png"}
    }})
    
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            -- WILL EXECUTE THIS ON DOUBLE CLICK
                if utils.double_click_event_handler() then
                    utils.change_titlebar_visibility(not c.maximized, c)
                    
                    c.maximized = not c.maximized
                    c:raise()
                else
                    awful.mouse.client.move(c)
                end
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            titlebarmenu:hide()
            awful.mouse.client.resize(c)
        end),
        awful.button({"Shift"}, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            titlebarmenu:toggle()
        end)
    )

    --15?
    awful.titlebar(c, {size = dpi(20)}) : setup {
        { -- Left
            utils.changewidgetbg(space, beautiful.color_array[1]),
            utils.changewidgetbg(awful.titlebar.widget.iconwidget(c), beautiful.color_array[1]),
            utils.changewidgetbg(space, beautiful.color_array[1]),
            sep.new("alpha", beautiful.color_array[1], sep.direction.LEFT, sep.type.TRAPEZIUM),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            sep.new(beautiful.color_array[1], "alpha", sep.direction.LEFT, sep.type.TRAPEZIUM),
            utils.maximizebutton(c),
            utils.close(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
    local borderconfig={
        ttargs = {size = dpi(1)},
        setupargs ={
            buttons = buttons,
            layout  = wibox.layout.fixed.vertical
        }
    }
    
    awful.titlebar(c,{position="left", size = borderconfig.ttargs.size}): setup(borderconfig.setupargs)
    awful.titlebar(c,{position="right", size = borderconfig.ttargs.size}): setup(borderconfig.setupargs)
    awful.titlebar(c,{position="bottom", size = borderconfig.ttargs.size}): setup(borderconfig.setupargs)
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}

--[[screen.connect_signal("arrange", function (s)
   for _, c in pairs(s.clients) do
        
    end
end)
]]