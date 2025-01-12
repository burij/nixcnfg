local conf, lib = require( "conf" ), require( "lib" )

--------------------------------------------------------------------------------

function application()
    local load_index = loadfile(conf.index_path)
    local index = load_index()

    local install_file_pkgs = lib.new_files_packages(index.files)
    local link_files = lib.link_files(index.files)
    local link_folders = lib.link_folders(index.folders)

    local script = lib.compose_list(
        link_folders,
        install_file_pkgs,
        link_files,
        index.commands)

    lib.do_cmd_list(script)

end

--------------------------------------------------------------------------------

function lib.escape_path(x)
    -- Helper function to properly escape paths with spaces
    lib.types(x, "string") -- input path
    local str = '"' .. x:gsub('"', '\\"') .. '"'
    return str
end

---


function lib.copy_content(x)
    -- move content of the folders, which do not exist, to dotfiles
    lib.types( x, "table" )
    local tbl = {}
    for k, v in pairs(x) do
        local pkg = lib.escape_path(conf.dotfiles_path .. k)
        local injection = "/home/" .. conf.user_name
        local absolute_target = lib.inject_var(v, "$HOME", injection)
        if lib.folder_exists(pkg) == false 
        and lib.folder_exists(absolute_target) == true then
            local a = "mkdir -p " .. pkg 
                .. " && cp -r " .. lib.escape_path(v) .. "/* " .. pkg
            table.insert(tbl, a)
        end
    end
    return tbl
end

---

function lib.link_folder_pkgs(x)
    -- delete target and link source to target
    lib.types( x, "table" )
    tbl = {}
    for k, v in pairs(x) do
        local parent = string.match(v, "(.*)/.*")
        local a = "rm -r "
            .. lib.escape_path(v)
            .. " && mkdir -p "
            .. lib.escape_path(parent)
            .. " && ln -sv "
            .. lib.escape_path(conf.dotfiles_path
            .. k)
            .. " "
            .. lib.escape_path(v)
        table.insert(tbl, a )
    end
    return tbl
end

---

function lib.link_folders(x)
    -- returns all bash commands which do needs to be done with folders
    lib.types( x, "table" )
    local copy_content = lib.copy_content(x)
    local linking = lib.link_folder_pkgs(x)
    tbl = lib.compose_list(copy_content, linking)
    return tbl
end

---

function lib.copy_files(x)
    -- creates list of commands to copy files to new folders
    lib.types( x, "table" )
    local tbl = {}
    for k, v in pairs(x) do
        local target = lib.escape_path(conf.dotfiles_path .. k)
        for k, v in pairs(v) do
            local source = lib.escape_path(v)
            table.insert(tbl, "cp " .. source .. " " .. target .. "/")
        end
    end
    return tbl
end

----

function lib.make_folders(x)
    -- creates a list of commands to make new folders
    lib.types( x, "table" )
    local tbl = {}
    for k, v in pairs(x) do
        local make_folder = "mkdir -p "
            .. lib.escape_path(conf.dotfiles_path .. k)
        table.insert(tbl, make_folder)
    end
    return tbl
end

---

function lib.folder_exists(x)
-- checks for existence of a folder
    lib.types( x, "string" ) --folder path
    -- Remove escaping for os.rename check
    local clean_path = string.gsub(x, "\\(.)", "%1")
    local success, _, code = os.rename(clean_path, clean_path)
    local bool = success or code == 13
    return bool
end

---

function lib.filter_new_pkgs(x)
-- checks for existens of folders and returns filtered table
    lib.types( x, "table" )
    local tbl = {}
    for k, v in pairs(x) do
        local path = conf.dotfiles_path .. k
        local exists = lib.folder_exists(path)
        if exists == false then
            tbl[k] = v
        end
    end
    return tbl
end

---

function lib.new_files_packages(x)
-- returns list of commands to create folders and copy files
    lib.types( x, "table" )
    local tbl = {}
    local new_pkgs = lib.filter_new_pkgs(x)
    local folder_creation = lib.make_folders(new_pkgs)
    local copy_files = lib.copy_files(new_pkgs)
    local tbl = lib.compose_list(folder_creation, copy_files)
    return tbl
end

---

function lib.link_files(x)
-- returns list of commands to symlink dotfiles
    lib.types( x, "table" )
    local tbl = {}
    for k, v in pairs(x) do
        for _, v in ipairs(v) do
            local prefix = "ln -sfv " ..  lib.escape_path(conf.dotfiles_path)
            local parent = string.match(v, "(.*)/.*")
            local make_parent = "mkdir -p " .. lib.escape_path(parent)
            local file = string.match(v, ".*/(.*)")
            table.insert(tbl, make_parent)
            table.insert(
                tbl, prefix
                    .. k
                    .. "/"
                    .. lib.escape_path(file)
                    .. " "
                    .. lib.escape_path(v)
            )
        end
    end
    return tbl
end

--------------------------------------------------------------------------------
application()
