# host specific settings


{ config, lib, pkgs, modulesPath, ... }:{

	networking.hostName = "macbook";

################################################################################

	imports =
	[
		(modulesPath + "/installer/scan/not-detected.nix")
		../../config.nix
		
	];

################################################################################

	boot.initrd.availableKernelModules = [
		"xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"
	];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" "wl" ];
	boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

	fileSystems."/" =
	{ device = "/dev/disk/by-uuid/1c9f7aa0-5323-4bf4-b6ee-4f938d37b89d";
	  fsType = "ext4";
	};

	fileSystems."/boot" =
	{ device = "/dev/disk/by-uuid/CF31-90BE";
	  fsType = "vfat";
	};

	swapDevices =
	[ { device = "/dev/disk/by-uuid/a5f3c9a1-4fd0-437f-bdf8-049034275924"; }
	];

	networking.useDHCP = lib.mkDefault true;
	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

	hardware.cpu.intel.updateMicrocode =
		lib.mkDefault config.hardware.enableRedistributableFirmware;

################################################################################

	services.xserver = {
		layout = "za";
		xkbVariant = "";
	};



################################################################################

system.stateVersion = "23.11";
}
