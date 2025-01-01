local conf, f = require( "conf" ), require( "lib" )

conf.srv = {
    title    = "Server Administration\n",
    path     = "/srv/config",
    config   = "/srv/config/docker-compose.yml",
    bu_path  = "/srv/backups",
    vol_path = "/srv/docker/volumes"
}

conf.srv.update = "sudo docker stop $(sudo docker ps -a -q); "
    .. "cd " .. conf.srv.path .. "; "
    .. "sudo docker compose pull; "
    .. "docker images --format '{{.Repository}}:{{.Tag}}' | "
    .. "xargs -L1 docker pull; "
    .. "sudo docker compose up -d; "
    .. "sleep 30; "
    .. "sudo docker image prune -a; "
    .. "sleep 30; "
    .. "echo  'do not forget to start nextcloud'; "
    .. "echo  'https://box:8080'; "
    .. "cd $HOME"


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
            .. "_burij_Sicherung_config " 
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

-- 	THEN=$(date +%Y-%m-%d)
-- 	NAMEV="burij_Sicherung_volumes"
-- 	SOURCEV="/srv/docker/volumes"
-- 	NAMEC="burij_Sicherung_config"
-- 	SOURCEC="/srv/config"
-- 	NAME="nextcloud-aio-nextcloud"
-- 	WHAT="sudo docker exec"


-- if [ $# -eq 0 ]; then
-- echo "
-- Usage: server
-- 		-u	update all images
-- 		-e	open compose project
-- 		-s	start server
-- 		-b	backup configs and volumes
-- 		-k	shut down server
-- 		-p	delete docker mess
-- 		-ns	rescan nextcloud-files
-- 		-be	open blog as builder project
-- 		-bu	update blog
-- "
--     exit 1
-- fi



-- elif [ "$1" == "-s" ]; then
-- 	cd /srv/config
-- 	sudo docker compose up -d
-- 	sleep 30

-- elif [ "$1" == "-k" ]; then
-- 	sudo docker stop $(sudo docker ps -a -q)


-- elif [ "$1" == "-p" ]; then
-- 	sudo docker stop $(sudo docker ps -a -q)
-- 	sudo docker rm $(sudo docker ps -a -q)
-- 	sudo docker rmi $(sudo docker images -qf "dangling=true")


-- elif [ "$1" == "-ns" ]; then
-- 	$WHAT $NAME chown -R 33:0 /srv/ncdata/ -v
-- 	$WHAT $NAME chmod -R 750 /srv/ncdata/ -v
-- 	$WHAT --user www-data -it $NAME php occ files:scan --all -v


-- elif [ "$1" == "-be" ]; then
-- 	flatpak run org.gnome.Builder -p /srv/config/blog/


-- elif [ "$1" == "-bu" ]; then
-- 	cd $HOME/Projekte/2311_burij.de/blog/
-- 	nix-shell --run "sh build"





