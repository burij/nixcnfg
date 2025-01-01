index = {}
--------------------------------------------------------------------------------
index.folders = {
    applications = "$HOME/.local/share/applications",
    darktable = "$HOME/.config/darktable",
    flatpak = "$HOME/.local/share/flatpak",
    fonts = "$HOME/.local/share/fonts",
    icons = "$HOME/.local/share/icons",
    obsidian_vault = "/data/burij/.obsidian",
    folder_space = "$HOME/folder space"
}

index.files = {
    bash = {"$HOME/.bash_history" },
    blender = { "$HOME/.config/blender/4.2/config/userpref.blend" },
    brave = { 
        "$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences",
        "$HOME/.config/BraveSoftware/Brave-Browser/Local State"
    },
    builder = { 
        "$HOME/.var/app/org.gnome.Builder/config/glib-2.0/settings/keyfile",
        "$HOME/.var/app/org.gnome.Builder/config/gnome-builder/keybindings.json"
    },
    defaultapps = { "$HOME/.config/mimeapps.list" },
    dirs = { 
        "$HOME/.config/user-dirs.dirs",
        "$HOME/.config/user-dirs.locale"
    },
    ghostwriter = { "$HOME/.config/kde.org/ghostwriter.conf" },
    gitnuro = { 
        "$HOME/.config/gitnuro/.java/.userPrefs/GitnuroConfig/prefs.xml"
    },
    grsync = { "$HOME/.config/grsync/grsync.ini"},
    gtk3 = { 
        "$HOME/.config/gtk-3.0/bookmarks",
        "$HOME/.config/gtk-3.0/settings.ini"
    },
    gtk4 = { 
        "$HOME/.config/gtk-4.0/servers",
        "$HOME/.config/gtk-4.0/settings.ini"
    },
    krenamer = { "$HOME/.config/krenamerc" },
    masterpdf = { 
        "$HOME/.config/Code Industry/Master PDF Editor 5.conf"
    },
    motrix = {
        "$HOME/.config/Motrix/user.json",
        "$HOME/.config/Motrix/system.json"
    },
    obsidian = {
        "$HOME/.config/obsidian/Preferences",
        "$HOME/.config/obsidian/obsidian.json",
        "$HOME/.config/obsidian/Dictionaries/de-DE-3-0.bdic",
        "$HOME/.config/obsidian/Dictionaries/en-US-10-1.bdic"
    },
    ocenaudio = {
        "$HOME/.local/share/ocenaudio/ocenaudio.settings"
    },
    ptyxis = {
        "$HOME/.config/org.gnome.Ptyxis/session.gvariant"
    },
    server = {
        "/srv/config/docker-compose.yml"
    },
    tenacity = {
        "$HOME/.config/tenacity/tenacity.cfg",
        "$HOME/.config/tenacity/pluginsettings.cfg",
        "$HOME/.config/tenacity/Theme/ImageCache.htm",
        "$HOME/.config/tenacity/Theme/ImageCache.png"
    },
    thunderbird = {
        "$HOME/.thunderbird/profiles.ini",
        "$HOME/.thunderbird/key4.db",
        "$HOME/.thunderbird/logins.json",
        "$HOME/.thunderbird/permissions.sqlite",
        "$HOME/.thunderbird/prefs.js",
        "$HOME/.thunderbird/xulstore.json"
    }
    
}

index.commands = {
    "dconf load / < /data/$USER/System/dotfiles/gnome-shell/dconf-settings.ini"
}

index.export = [[
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
	cp -fv $HOME/.config/obsidian/Preferences \
	$SOURCE/obsidian/Preferences
]]

--------------------------------------------------------------------------------
return index