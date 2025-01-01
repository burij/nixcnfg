{ config, pkgs, ... }:{

################################################################################
	imports =
	[
		./pkgs/offtree.nix
	];

################################################################################

	nixpkgs.overlays = [(self: super: {
		# ocenaudio = super.ocenaudio.overrideAttrs (oldAttrs: rec {
		# version = "3.13.8";
		# src = super.fetchurl {
		# 	url = "https://www.ocenaudio.com/downloads/index.php/"
		# 	+ "ocenaudio_debian9_64.deb?version=${version}";
		# 	sha256 = "sha256-Oo2AqQSzcQPsA9Aias+nWt3ChyAeAt7wCc0MfzK1dYY=";
		#   	};
		# 	});

		# obsidian = super.obsidian.overrideAttrs (oldAttrs: rec {
		# 	src = super.fetchurl {
		# 		url = "https://github.com/obsidianmd/obsidian-releases/"
		# 		+ "releases/download/v1.6.5/obsidian-1.6.5.tar.gz";
		# 		sha256 = "sha256-ho8E2Iq+s/w8NjmxzZo/y5aj3MNgbyvIGjk3nSKPLDw=";
		#   	};
		# });

		# sunvox = super.sunvox.overrideAttrs (oldAttrs: rec {
		# 	src = super.fetchzip {
		# 		url = "https://www.warmplace.ru/soft/sunvox/sunvox-2.1.2.zip";
		# 		hash = "sha256-7DZyoOz3jDYsuGqbs0PRs6jdWCxBhSDUKk8KVJQm/3o=";
		#   	};
		# });


	})];


################################################################################


	environment.systemPackages = with pkgs; [
        # libsForQt5.ghostwriter
        # nextcloud-client
        adwaita-icon-theme
        amberol
        apostrophe
        # bitwarden-desktop
        # bottles
        bottom
        blender
        brave
        celluloid
        code-cursor
        darktable
        dconf-editor
        distrobox
        eartag
        eyedropper
        firefox
        flatpak
        gimp
        git
        gitnuro
        # gnome-builder
        # gnome-extension-manager
        gnome-software
        gnome-sound-recorder
        gnome-tweaks
        gnomeExtensions.appindicator
        gnomeExtensions.auto-activities
        gnomeExtensions.blur-my-shell
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.compiz-windows-effect
        gnomeExtensions.coverflow-alt-tab
        gnomeExtensions.dash-to-dock
        gnomeExtensions.desktop-cube
        gnomeExtensions.forge
        gnomeExtensions.launcher
        gnomeExtensions.night-theme-switcher
        gnomeExtensions.open-bar
        gnomeExtensions.status-area-horizontal-spacing
        gnomeExtensions.tiling-shell
        gparted
        grsync
        helvum
        home-manager
        inkscape
        khronos
        krename
        libnotify
        libreoffice-fresh
        libsForQt5.kdenlive
        masterpdfeditor
        # mixxx
        motrix
        nemo-with-extensions
        neofetch
        newsflash
        ntfs3g
        nushell
        nvd
        obs-studio
        obsidian
        ocenaudio
        pkgs.libsForQt5.okular
        # playonlinux
        ptyxis
        scribus
        sunvox
        steam-run
        stow
        tenacity
        thunderbird
        unzip
        wget
        zip
	];


################################################################################

	fonts.packages = with pkgs; [
        aileron
        corefonts
        dina-font
        fira-code
        fira-code-symbols
        helvetica-neue-lt-std
        inter
        liberation_ttf
        mplus-outline-fonts.githubRelease
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        proggyfonts
        ubuntu_font_family
        vistafonts
        wineWowPackages.fonts
	];

################################################################################



    programs.bash.shellAliases = {
        dev = "flatpak run org.gnome.Builder -p .";
        shell = "nix-shell";
        box = "ssh burij@box";
        system = "cd /data/$USER/System/setup/ && "
          + "chmod +x ./run && ./run && cd $HOME";
    };


################################################################################

	users.users.burij = {
		isNormalUser = true;
		description = "burij";
		extraGroups = [ "networkmanager" "wheel" "docker" "lp" ];
		packages = with pkgs; [ ];
	};

	users.users.leeni = {
		isNormalUser = true;
		description = "leeni";
		extraGroups = [ "networkmanager" "wheel" "docker" ];
		packages = with pkgs; [ google-chrome ];
	};

	i18n.extraLocaleSettings = {
		LC_ADDRESS = "de_DE.UTF-8";
		LC_IDENTIFICATION = "de_DE.UTF-8";
		LC_MEASUREMENT = "de_DE.UTF-8";
		LC_MONETARY = "de_DE.UTF-8";
		LC_NAME = "de_DE.UTF-8";
		LC_NUMERIC = "de_DE.UTF-8";
		LC_PAPER = "de_DE.UTF-8";
		LC_TELEPHONE = "de_DE.UTF-8";
		LC_TIME = "de_DE.UTF-8";
	};

	time.timeZone = "Europe/Berlin";
	i18n.defaultLocale = "de_DE.UTF-8";

	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;	
	environment.gnome.excludePackages = with pkgs; [ geary gnome-terminal ];

	nixpkgs.config.allowUnfree = true;
	services.flatpak.enable = true;

	services.fwupd.enable = true;

	virtualisation.virtualbox.host.enable = true;
	virtualisation.docker.enable = true;

	networking.networkmanager.enable = true;

	services.printing.enable = true;
        services.printing.drivers = [ pkgs.brlaser ];
        services.avahi.enable = true;
        services.avahi.nssmdns4 = true;

	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};

	hardware.graphics.enable32Bit = true;
	security.sudo.extraConfig = "Defaults env_reset,pwfeedback";
	programs.dconf.enable = true;


	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.efi.efiSysMountPoint = "/boot";
	boot.plymouth.enable = true;
	boot.plymouth.theme="fade-in";
		# themes: bgrt, breeze, breeze-text, details, fade-in, glow, script
		# solar,  spinfinity, spinnerm, text, tribar
	boot.initrd.systemd.enable = true;
	boot.kernelParams = ["quiet"];
	boot.consoleLogLevel = 0;


	nix.gc = {
	  	automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
        };


	fileSystems."/home/burij/Projekte" = {
		device = "/data/burij/Projects";
		fsType = "none";
		options = [ "bind" ];
	};

	fileSystems."/home/burij/Desktop" = {
		device = "/data/burij/Desktop";
		fsType = "none";
		options = [ "bind" ];
	};

	fileSystems."/home/burij/System" = {
		device = "/data/burij/System";
		fsType = "none";
		options = [ "bind" ];
	};

	fileSystems."/home/burij/Vorlagen" = {
		device = "/data/burij/Templates";
		fsType = "none";
		options = [ "bind" ];
	};

	fileSystems."/home/burij/Notizbuch" = {
		device = "/data/burij/Notebook";
		fsType = "none";
		options = [ "bind" ];
	};

	fileSystems."/home/burij/Virtuelles USB" = {
		device = "/data/burij/Virtual USB";
		fsType = "none";
		options = [ "bind" ];
	};

	fileSystems."/home/burij/SunVox" = {
		device = "/home/burij/Projekte/2331_SunvoxStudio";
		fsType = "none";
		options = [ "bind" ];
    };



################################################################################
}
