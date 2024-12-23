{ config, pkgs, lib, modulesPath, ... }:

{
  imports =
    [
        ./hardware.nix
        ../../config.nix
        ../../scripts/server.nix
    ];


    networking.hostName = "box";
    system.stateVersion = "23.11";

    virtualisation.docker.enable = true;

    # virtualisation.docker.rootless = {
    # enable = true;
    # setSocketVariable = true;
    # };
    # rootless docker doesn't work together with distrobox

    virtualisation.docker.daemon.settings = {
     data-root = "/srv/docker";
    };

    services.openssh.enable = true;

    networking.firewall.allowedTCPPortRanges = [
      { from = 80; to = 81; }
      { from = 443; to = 443; }
      { from = 7000; to = 7100; }
      { from = 8080; to = 8888; }
      { from = 2999; to = 2999; }
      { from = 9080; to = 9080; }
    ];

    environment.systemPackages = with pkgs; [
    lazydocker
    ];

    fileSystems."/home/burij/Media" = {
    device = "/srv/media";
    fsType = "none";
    options = [ "bind" ];
    };


}
