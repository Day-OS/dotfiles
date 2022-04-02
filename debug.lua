local n = require("naughty")

function DebugPrint(txt)
    n.notify({preset=n.config.presets.normal, title="debug", text=txt})
end

local gears = require("gears")
DebugPrint(gears.filesystem.get_themes_dir())