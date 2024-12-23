conf = {}
--------------------------------------------------------------------------------
conf = {
    host          = nil, -- nil or replace with a 'string' on a new machine
    link_to_home  = false, -- links /etc/nixos/configuration.nix to System
    add_unstable  = false, -- adds unstable channel
    register_host = false, -- be careful with this one! resets your host-config
    userconfig    = true, -- links dotfiles to System
    rmdirs        = true, -- removes unnecessary folders from home
    flatpaks      = true, -- install flatpaksupport and flatpaks from the list
    rebuild       = false, -- rebuild system in the end
}

conf.user_name = os.getenv("USER")
conf.root_path = "/data/" .. conf.user_name .. "/System/"
conf.dotfiles_path =  conf.root_path .. "dotfiles/"
-- conf.dotfiles_path =  "/data/" .. conf.user_name .. "/System/dotfiles/"
conf.index_path = conf.dotfiles_path .. "index.lua"

conf.dirs_to_remove = {
    "Downloads",
    "Musik",
    "Dokumente",
    "Bilder",
    "Öffentlich",
    "Videos",
    "Screenshots"
}

conf.flatpak_list = {
    "page.codeberg.libre_menu_editor.LibreMenuEditor",
    "org.gnome.Builder",
    "io.beekeeperstudio.Studio",
    "com.mattjakeman.ExtensionManager",
    "org.onlyoffice.desktopeditors",
    "com.github.jeromerobert.pdfarranger",
    "org.gustavoperedo.FontDownloader",
    "com.nextcloud.desktopclient.nextcloud",
    "net.natesales.Aviator",
    "org.jdownloader.JDownloader",
    "de.schmidhuberj.DieBahn",
    "com.github.xournalpp.xournalpp",
    "com.github.unrud.VideoDownloader",
    "org.zrythm.Zrythm"
}

conf.flatpak_postroutine = {
    "flatpak run --command=gsettings com.github.unrud.VideoDownloader set "
    .. "com.github.unrud.VideoDownloader "
    .. "download-folder '~/Virtuelles USB/Vinylcase'",
    "flatpak override --user "
    .. "--filesystem='~/Virtuelles USB/Vinylcase:create' "
    .. "com.github.unrud.VideoDownloader"
}

conf.own_etcnixos = {
    "sudo chown $USER /etc/nixos/",
    "sudo chown $USER /etc/nixos/configuration.nix",
    "sudo chmod u+w /etc/nixos/configuration.nix"
}

conf.rebuild_cmd = "sudo nixos-rebuild boot"

conf.flatpak_support =  { "flatpak remote-add --if-not-exists "
    .. "flathub https://flathub.org/repo/flathub.flatpakrepo",
    "flatpak update -y" }

conf.fp_install_cmd = "flatpak install --system flathub "

conf.drm_cmd = "rm -r $HOME/"

conf.symlink = "lua /data/$USER/System/setup/dotfiles.lua"

conf.add_channel = "sudo nix-channel --add "
conf.unstable = "https://nixos.org/channels/nixos-unstable nixos"

--------------------------------------------------------------------------------
-- TEMPLATES

conf.template_etcnixos = [[
{ config, pkgs, ... }:
{
  imports =
    [
      ./System/hosts/$HOSTNAME/config.nix
    ];
}
]]

---

conf.template_host = [[
{ config, pkgs, lib, modulesPath, ... }:
{

	networking.hostName = "$HOSTNAME";
	system.stateVersion = $VERSION;

	imports =
	[
		../../config.nix
		./hardware.nix
		# <nixpkgs/nixos/modules/installer/virtualbox-demo.nix>

	];
}
]]

--------------------------------------------------------------------------------
return conf
