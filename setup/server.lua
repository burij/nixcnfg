local conf, f = require( "conf" ), require( "lib" )

--------------------------------------------------------------------------------

local function application()

    local function back_to_main()
        dofile( "main.lua" )
    end

    local function update()
        os.execute(conf.srv.update)
    end
    
    local function back_up()
        local stamp = os.date("%Y-%m-%d")
        os.execute( 
            "sudo tar -zcvf " 
            .. conf.srv.bu_path 
            .. "/" 
            .. stamp 
            .. "_burij_Sicherung_config.tar.gz " 
            .. conf.srv.path
        )
        os.execute( 
            "sudo zip -r " 
            .. conf.srv.bu_path 
            .. "/" 
            .. stamp 
            .. "_burij_Sicherung_volumes " 
            .. conf.srv.vol_path 
        )
    end

    local function run_srv()
        os.execute( "cd " .. conf.srv.path .. " && sudo docker compose up -d" )
    end

    local function stop_srv()
        os.execute( "sudo docker stop $(sudo docker ps -a -q)" )
    end
    
    local function gc_collect()
        os.execute( 
            "sudo docker stop $(sudo docker ps -a -q); "
            .. "sudo docker rm $(sudo docker ps -a -q); "
            .. "sudo docker rmi $(sudo docker images -qf 'dangling=true')"
        )
    end

    local function scan_nc()
        os.execute( 
	        conf.srv.docker 
	        .. conf.srv.nc 
	        .. "chown -R 33:0 /srv/ncdata/ -v; "
	        .. conf.srv.docker 
	        .. conf.srv.nc 
	        .. "chmod -R 750 /srv/ncdata/ -v; "
	        .. conf.srv.docker 
	        .. "--user www-data -it" 
	        .. conf.srv.nc 
	        .. "php occ files:scan --all -v"
        )
    end

    local function blog_entry()
        os.execute( conf.srv.blog )
    end

    local function edit_home()
        os.execute( conf.srv.home )
    end

    local function edit_conf()
        os.execute("nano " .. conf.srv.config)
    end

    local menu = {
        title = conf.srv.title,
        message = "Use arrow keys to navigate, 'enter' to select",
        options = {
            { text = "Back to main menu", action = back_to_main },
            { text = "Update images", action = update },
            { text = "Back up config and volumes", action = back_up },
            { text = "Start up server", action = run_srv },
            { text = "Shut down server", action = stop_srv },
            { text = "Delete docker garbage", action = gc_collect },
            { text = "Rescan Nextcloud files", action = scan_nc },
            { text = "Write blog entry", action = blog_entry },
            { text = "Edit homepage", action = edit_home },
            { text = "Settings", action = edit_conf },
            { text = "Exit", action = function() os.exit() end }
        },
        selected = 1
    }
    f.do_draw_menu(menu)
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
application()
