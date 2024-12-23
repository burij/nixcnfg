{ pkgs, ... }:

let
system = pkgs.writeShellScriptBin "system"
''
################################################################################


if [ $# -eq 0 ]; then
echo "
Usage: system
		-u  rebuild according to $HERE and upgrade all packages
		-a  rebuild without upgrading
		-s  run system setup tool
		-e  open system configuration as builder project
		-c  run upgrade check without applying
		-p  purge: remove old generations and unused flatpacks
		-b  back up gnome-shell settings and brave, ptyxis, mime state
"
    exit 1
fi

HERE="$HOME/System/hosts/$HOSTNAME/config.nix"
LOGS="$HOME/System/update.log"


# Check the value of the first argument
if [ "$1" == "-u" ]; then
	echo "NixOS update..."
	sudo nixos-rebuild switch --upgrade
	nixos-rebuild list-generations | grep current
	notify-send -e "NixOS upgrade finished" --icon=software-update-available


elif [ "$1" == "-a" ]; then
	echo "NixOS rebuild..."
	sudo nixos-rebuild switch --upgrade -I nixos-config=$HERE
	nixos-rebuild list-generations | grep current
	notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available

elif [ "$1" == "-s" ]; then
    cd /data/$USER/System/setup/
	chmod +x ./run
	./run
	cd ..


elif [ "$1" == "-e" ]; then
	flatpak run org.gnome.Builder -p /data/burij/System


elif [ "$1" == "-c" ]; then
	sudo nix-channel --update
	sudo nixos-rebuild build -I nixos-config=$HERE
	nvd diff /run/current-system ./result
	rm result


elif [ "$1" == "-p" ]; then
	flatpak uninstall --unused
	nix-collect-garbage
	sudo nix-collect-garbage
	nix-collect-garbage -d
	sudo nix-collect-garbage -d
	sudo nixos-rebuild boot --upgrade -I nixos-config=$HERE
	sudo nixos-rebuild switch --upgrade -I nixos-config=$HERE


elif [ "$1" == "-b" ]; then
		dconf dump / > /data/$USER/System/dotfiles/gnome-shell/dconf-dump.ini
		SOURCE="/data/$USER/System/dotfiles"
		FP=$HOME"/.var/app"
		cp -fv $HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences \
		$SOURCE/brave/Preferences
		cp -fv $HOME/.config/BraveSoftware/Brave-Browser/Local\ State \
		$SOURCE/brave/Local\ State
		cp -fv $HOME/.config/org.gnome.Ptyxis/session.gvariant \
		$SOURCE/ptyxis/session.gvariant
		cp -fv $HOME/.config/mimeapps.list \
		$SOURCE/defaultapps/mimeapps.list


else
    echo "Unknown option: $1. Run without arguments, to see help."
    exit 1
fi




################################################################################
'';
in {
  environment.systemPackages = [ system ];
}
