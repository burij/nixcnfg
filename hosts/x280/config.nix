{ config, pkgs, lib, modulesPath, ... }:
{

	networking.hostName = "x280";
	system.stateVersion = "23.05";

	imports =
	[
		../../config.nix
		./hardware.nix
	];
}
