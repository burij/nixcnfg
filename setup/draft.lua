local conf, lib = require( "conf" ), require( "lib" )

--------------------------------------------------------------------------------
-- conf

conf.window_flags = {
    resizable=false,
    vsync=true,
    minwidth=400,
    minheight=300
}

conf.window_title = "nixos post-installer"

conf.symlink_system = "ln -sfv /data/$USER/System /etc/nixos"
conf.back_up_path = "/etc/nixos/configuration." .. os.time()

conf.own_etcnixos = {
    "sudo chown $USER /etc/nixos/",
    "sudo chown $USER /etc/nixos/configuration.nix",
    "sudo chmod u+w /etc/nixos/configuration.nix"
}

conf.add_channel = "sudo nix-channel --add "
conf.unstable = "https://nixos.org/channels/nixos-unstable nixos"

conf.rebuild_cmd = "sudo nixos-rebuild boot"

conf.flatpak_support =  { "flatpak remote-add --if-not-exists"
    .. "flathub https://flathub.org/repo/flathub.flatpakrepo",
    "flatpak update -y" }


--------------------------------------------------------------------------------
-- lib

function lib.do_link_to_home(x, y, z)
    lib.types( x, "boolean" )
    lib.types( y, "string" )
    lib.types( z, "string" )
    if x then
        lib.do_cmd_list (conf.own_etcnixos)
        lib.do_cmd(conf.symlink_system)
        lib.do_write_file( conf.back_up_path, z )
        lib.do_write_file( "/etc/nixos/configuration.nix", y )
    end
end

---

function lib.do_folder(x)
    lib.types( x, "string" )
    local current_user = os.getenv("USER")
    local check_cmd = "if [ -d "
        .. x
        .. " ]; then echo 'exists'; else echo 'not exists'; fi"
    local folder_status = lib.do_cmd(check_cmd):gsub("%s+", "")
    if folder_status == "notexists" then
        local mkdir_cmd = "sudo mkdir -p " .. x
        lib.do_cmd(mkdir_cmd)
    else
        print("Folder already exists: " .. x)
    end
    local chown_cmd = "sudo chown -R $USER:users " .. x
    lib.do_cmd(chown_cmd)
end

---

function lib.do_register_host( x, y, z )
    lib.types( x, "boolean" )
    lib.types( y, "string" )
    lib.types( z, "string" )
    if x then
        local hard_path = "/etc/nixos/hardware-configuration.nix"
        local orig_hard = lib.do_get_file_content ( hard_path )
        local host_folder = "/data/" .. y .. "/System/hosts/" .. z .. "/"
        local conf_path = host_folder .. "config.nix"
        local hard_path = host_folder .. "hardware.nix"
        local host_conf = lib.inject_var(conf.template_host, "$HOSTNAME", z)
        local cmd_get_version = "nix-instantiate --eval"
            .. " '<nixos/nixos>' -A config.system.stateVersion"
        local system_version = lib.command_and_capture(cmd_get_version, "ERROR")
        print(system_version)
        local host_conf_with_version = lib.inject_var(
            host_conf, "$VERSION", system_version
        )
        lib.do_folder( host_folder )
        lib.do_write_file(conf_path, host_conf_with_version)
        lib.do_write_file(hard_path, orig_hard)
    end
end

---

function lib.do_userconfig (x)
    lib.types( x, "boolean" )
    if x then
        lib.do_cmd( "sh /data/$USER/System/dotfiles/symlink" )
    end
end

---

function lib.do_rmdirs( x )
    lib.types( x, "boolean" )
    local rm_cmd = "rm -r $HOME/"
    local cmd_tbl = lib.extend_table(conf.dirs_to_remove, rm_cmd, "")
    if x then
        lib.do_cmd_list( cmd_tbl )
    end
end


---
function lib.do_flatpaks (x, y)
    lib.types( x, "boolean" )
    lib.types( y, "table" )
    local flatpak_support =  {
        "flatpak remote-add --if-not-exists "
        .. "flathub https://flathub.org/repo/flathub.flatpakrepo",
        "flatpak update -y"
    }
    local flatpak_install = lib.extend_table(
        conf.flatpak_list, "flatpak install --system flathub ", " -y"
    )
    if x then
        lib.do_cmd_list (flatpak_support)
        lib.do_cmd_list (flatpak_install)
        lib.do_cmd_list (conf.flatpak_postroutine)
    end
end

---

function lib.compose_list(...)
-- given any amount of strings or string lists in tables, returns them as table
    local tbl = {}
    for _, v in ipairs({...}) do
        if type(v) == "string" then
            table.insert(tbl, v)
        elseif type(v) == "table" then
            for _, str in ipairs(v) do
                if type(str) ~= "string" then
                    error("incorrect table format detected")
                end
                table.insert(tbl, str)
            end
        else
            error("all arguments must be either strings or tables")
        end
    end
    return tbl
end

---

function lib.skip_bash(x)
-- adds skip command to a string
    lib.types( x, "string" )
    var = ": || skipping " .. x
    return var
end

---

function lib.itself_if_true(x, y)
-- returns string x back, if y is true, otherways wraps it in skip commands
    lib.types( x, "string" )
    lib.types( y, "boolean" )
    if y then
        var = x
    else
        var = ": || skipping " .. x
    end
    return var
end

---

function lib.fp_installer (x)
-- given list with flatpacks, returns script, which installs apps
    lib.types( x, "boolean" )
    if x then
        local cmd_tbl = lib.extend_table(
            conf.flatpak_list, "flatpak install --system flathub ", " -y"
        )
        str = table.concat(cmd_tbl, "; ")
    else
        str = " "
    end
    return str
end

---

function lib.table_if_true(x, y)
    -- returns table with strings, if condition false - wraps each in skip commands
        lib.types(x, "table")
        lib.types(y, "boolean")
        local tbl = {}
        for _, str in ipairs(x) do
            lib.types(str, "string")
            if condition then
                table.insert(result, str)
            else
                table.insert(result, ": || skipping " .. str)
            end
        end
        return tbl
    end

--------------------------------------------------------------------------------

-- refactoring in process
local function application()
    local user = lib.command_and_capture("whoami", "default")
    local host = conf.host or lib.command_and_capture("hostname", "default")
    local orig_conf = lib.do_get_file_content ( "/etc/nixos/configuration.nix" )
    local add_unstable = conf.add_channel .. conf.unstable
    local etcnixos = lib.inject_var(conf.template_etcnixos, "$HOSTNAME", host)

    lib.do_link_to_home(conf.link_to_home, etcnixos, orig_conf)
    lib.do_if_true(add_unstable, conf.add_unstable)
    lib.do_register_host( conf.register_host, user, host )
    lib.do_userconfig(conf.userconfig)
    lib.do_rmdirs( conf.rmdirs )
    lib.do_flatpaks(conf.flatpaks, conf.flatpak_list)
    lib.do_if_true( conf.rebuild_cmd, conf.rebuild )
    
end application()


