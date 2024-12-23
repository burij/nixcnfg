{ pkgs, ... }:

let
server = pkgs.writeShellScriptBin "server"
''
################################################################################

	THEN=$(date +%Y-%m-%d)
	NAMEV="burij_Sicherung_volumes"
	SOURCEV="/srv/docker/volumes"
	NAMEC="burij_Sicherung_config"
	SOURCEC="/srv/config"
	NAME="nextcloud-aio-nextcloud"
	WHAT="sudo docker exec"


if [ $# -eq 0 ]; then
echo "
Usage: server
		-u	update all images
		-e	open compose project
		-s	start server
		-b	backup configs and volumes
		-k	shut down server
		-p	delete docker mess
		-ns	rescan nextcloud-files
		-be	open blog as builder project
		-bu	update blog
"
    exit 1
fi


# Check the value of the first argument
if [ "$1" == "-u" ]; then
	sudo docker stop $(sudo docker ps -a -q)
	cd /srv/config
	sudo docker compose pull
	docker images --format "{{.Repository}}:{{.Tag}}" | xargs -L1 docker pull
	sudo docker compose up -d
	sleep 30
	sudo docker image prune -a
	sleep 30
	echo  "don't forget to start nextcloud"
	echo  "https://box:8080"


elif [ "$1" == "-e" ]; then
	gnome-text-editor /srv/config/docker-compose.yml


elif [ "$1" == "-s" ]; then
	cd /srv/config
	sudo docker compose up -d
	sleep 30


elif [ "$1" == "-b" ]; then
	sudo zip -r "/srv/backups/''${THEN}_$NAMEV" $SOURCEV
	sudo tar -zcvf "/srv/backups/''${THEN}_$NAMEC.tar.xz" $SOURCEC


elif [ "$1" == "-k" ]; then
	sudo docker stop $(sudo docker ps -a -q)


elif [ "$1" == "-p" ]; then
	sudo docker stop $(sudo docker ps -a -q)
	sudo docker rm $(sudo docker ps -a -q)
	sudo docker rmi $(sudo docker images -qf "dangling=true")


elif [ "$1" == "-ns" ]; then
	$WHAT $NAME chown -R 33:0 /srv/ncdata/ -v
	$WHAT $NAME chmod -R 750 /srv/ncdata/ -v
	$WHAT --user www-data -it $NAME php occ files:scan --all -v


elif [ "$1" == "-be" ]; then
	flatpak run org.gnome.Builder -p /srv/config/blog/


elif [ "$1" == "-bu" ]; then
	cd $HOME/Projekte/2311_burij.de/blog/
	nix-shell --run "sh build"



else
    echo "Unknown option: $1. Run without arguments, to see help."
    exit 1
fi





################################################################################
'';
in {
  environment.systemPackages = [ server ];
}