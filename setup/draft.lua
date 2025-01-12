local conf, f = require("conf"), require("lib")
--------------------------------------------------------------------------------
function f.channels_draft(x)
    f.types(x, "table")
    local tbl = {}
    local get_channels = f.command_and_capture(
        "sudo nix-channel --list",
        ""
    )
    local function str_to_table(x)
        f.types(x, "string")
        local tbl = {}
        for line in x:gmatch("[^\n]+") do
            table.insert(tbl, line)
        end
        return tbl
    end
    local current_channels = str_to_table(get_channels)
    local channels_div = f.tbl_div(current_channels, x)

    -- Process removes first
    local process_removes = f.map(channels_div.removed, function(x)
        f.types(x, "string")
        local name = x:match("(%S+)")
        return string.format("sudo nix-channel --remove %s", name)
    end)

    -- Then process installs with update after each add
    local process_installs = f.map(channels_div.added, function(x)
        f.types(x, "string")
        local name, url = x:match("(%S+)%s+(.*)")
        return string.format("sudo nix-channel --add %s %s && sudo nix-channel --update", url, name)
    end)

    -- Combine commands, no need for final update since each install does it
    local tbl = f.compose_list(process_removes, process_installs)
    return tbl
end