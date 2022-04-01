local n = require("naughty")

function stdcout(txt)
    n.notify({preset=n.config.presets.normal, title="debug", text=txt})
end

local gears = require("gears")
stdcout(gears.filesystem.get_themes_dir())