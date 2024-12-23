local conf, lib = require( "conf" ), require( "lib" )

-- conf.symlink_system = "ln -sfv /data/$USER/System /etc/nixos"
conf.symlink_system = "ln -sfv " .. conf.root_path .. " /etc/nixos"
conf.back_up_path = "/etc/nixos/configuration." .. os.time()

--------------------------------------------------------------------------------

local function application()
    local user = lib.command_and_capture("whoami", "default")
    local host = conf.host or lib.command_and_capture("hostname", "default")
    local orig_conf = lib.do_get_file_content ( "/etc/nixos/configuration.nix" )
    local etcnixos = lib.inject_var(conf.template_etcnixos, "$HOSTNAME", host)
    lib.do_link_to_home(conf.link_to_home, etcnixos, orig_conf)
    lib.do_register_host( conf.register_host, user, host )

    -- local first_phase = lib.compose_list()
    -- lib.do_cmd_list(first_phase)
    
    local add_unstable = conf.add_channel .. conf.unstable
    local fp_installer = lib.extend_table(
        conf.flatpak_list, conf.fp_install_cmd, " -y"
    )
    local folder_rm = lib.extend_table(conf.dirs_to_remove, conf.drm_cmd, "")
    local final_phase = lib.compose_list (
        lib.skipcmd_str_if_false(add_unstable, conf.add_unstable),
        lib.skipcmd_str_if_false(conf.symlink, conf.userconfig),
        lib.skipcmd_tbl_if_false(folder_rm, conf.rmdirs),
        lib.skipcmd_tbl_if_false(conf.flatpak_support, conf.flatpaks),
        lib.skipcmd_tbl_if_false(fp_installer, conf.flatpaks),
        lib.skipcmd_tbl_if_false(conf.flatpak_postroutine, conf.flatpaks),
        lib.skipcmd_str_if_false(conf.rebuild_cmd, conf.rebuild)
    )
    lib.do_cmd_list(final_phase)
    

    
end
--------------------------------------------------------------------------------

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
        local host_folder = conf.root_path .. "hosts/" .. z .. "/"
        -- local host_folder = "/data/" .. y .. "/System/hosts/" .. z .. "/"
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

--------------------------------------------------------------------------------
application()


