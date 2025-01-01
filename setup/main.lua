local conf, f = require( "conf" ), require( "lib" )

conf.symlink_system = "ln -sfv " .. conf.root_path .. " /etc/nixos"
conf.back_up_path = "/etc/nixos/configuration." .. os.time()

--------------------------------------------------------------------------------

local function application()

    local function upgrade()
        os.execute(conf.upgrade)
    end
    
    local function run_script()
        conf = f.reload_module( "conf" )
        local user = f.command_and_capture("whoami", "default")
        local host = conf.host or f.command_and_capture("hostname", "default")
        local orig_conf = f.do_get_file_content ( 
            "etc/nixos/configuration.nix" 
        )
        local etcnixos = f.inject_var(
            conf.template_etcnixos, "$HOSTNAME", host
        )
        f.do_link_to_home(conf.link_to_home, etcnixos, orig_conf)
        f.do_register_host( conf.register_host, user, host )
        
        local add_unstable = conf.add_channel .. conf.unstable
        local fp_installer = f.extend_table(
            conf.flatpak_list, conf.fp_install_cmd, " -y"
        )
        local folder_rm = f.extend_table(
            conf.dirs_to_remove, conf.drm_cmd, ""
        )
        local final_phase = f.compose_list (
            f.skipcmd_str_if_false(add_unstable, conf.add_unstable),
            f.skipcmd_str_if_false(conf.symlink, conf.userconfig),
            f.skipcmd_tbl_if_false(folder_rm, conf.rmdirs),
            f.skipcmd_tbl_if_false(conf.flatpak_support, conf.flatpaks),
            f.skipcmd_tbl_if_false(fp_installer, conf.flatpaks),
            f.skipcmd_tbl_if_false(conf.flatpak_postroutine, conf.flatpaks),
            f.skipcmd_tbl_if_false(conf.gc_collect, conf.purge),
            f.skipcmd_str_if_false(conf.rebuild_cmd, conf.rebuild)
        )
        f.do_cmd_list(final_phase)
    end
    
    local function just_dotfiles()
        dofile("dotfiles.lua")
    end
    
    local function export_dotfiles()
        conf = f.reload_module( "conf" )
        local load_index = loadfile(conf.index_path)
        local index = load_index()
        f.do_cmd(index.export)
    end
    
    local function server_admin()
        dofile("server.lua")
    end
    
    local function edit_conf()
        os.execute("nano ./conf.lua")
    end
    
    local function edit_nixconf()
        os.execute("nano " .. conf.root_path .. "config.nix")
    end

    local menu = {
        title = conf.title,
        message = "Use arrow keys to navigate, 'enter' to select",
        options = {
            { text = "Update system", action = upgrade },
            { text = "Rebuild", action = run_script },
            { text = "Relink dotfiles", action = just_dotfiles },
            { text = "Export dotfiles", action = export_dotfiles },
            { text = "Server administration", action = server_admin },
            { text = "NixOS configuration", action = edit_nixconf },
            { text = "Settings", action = edit_conf },
            { text = "Exit", action = function() os.exit() end }
        },
        selected = 1
    } 
    f.do_draw_menu(menu)
    
end
--------------------------------------------------------------------------------

function f.do_link_to_home(x, y, z)
    f.types( x, "boolean" )
    f.types( y, "string" )
    f.types( z, "string" )
    if x then
        f.do_cmd_list (conf.own_etcnixos)
        f.do_cmd(conf.symlink_system)
        f.do_write_file( conf.back_up_path, z )
        f.do_write_file( "/etc/nixos/configuration.nix", y )
    end
end

---

function f.do_folder(x)
    f.types( x, "string" )
    local current_user = os.getenv("USER")
    local check_cmd = "if [ -d "
        .. x
        .. " ]; then echo 'exists'; else echo 'not exists'; fi"
    local folder_status = f.do_cmd(check_cmd):gsub("%s+", "")
    if folder_status == "notexists" then
        local mkdir_cmd = "sudo mkdir -p " .. x
        f.do_cmd(mkdir_cmd)
    else
        print("Folder already exists: " .. x)
    end
    local chown_cmd = "sudo chown -R $USER:users " .. x
    f.do_cmd(chown_cmd)
end

---

function f.do_register_host( x, y, z )
    f.types( x, "boolean" )
    f.types( y, "string" )
    f.types( z, "string" )
    if x then
        local hard_path = "/etc/nixos/hardware-configuration.nix"
        local orig_hard = f.do_get_file_content ( hard_path )
        local host_folder = conf.root_path .. "hosts/" .. z .. "/"
        local conf_path = host_folder .. "config.nix"
        local hard_path = host_folder .. "hardware.nix"
        local host_conf = f.inject_var(conf.template_host, "$HOSTNAME", z)
        local cmd_get_version = "nix-instantiate --eval"
            .. " '<nixos/nixos>' -A config.system.stateVersion"
        local system_version = f.command_and_capture(cmd_get_version, "ERROR")
        print(system_version)
        local host_conf_with_version = f.inject_var(
            host_conf, "$VERSION", system_version
        )
        f.do_folder( host_folder )
        f.do_write_file(conf_path, host_conf_with_version)
        f.do_write_file(hard_path, orig_hard)
    end
end

--------------------------------------------------------------------------------
application()


