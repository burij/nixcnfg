{ config, pkgs, lib, modulesPath, ... }:
{

	networking.hostName = "ThinkPad";
	system.stateVersion = "23.11";

	imports =
	[
		../../config.nix
		./hardware.nix
	];
}
