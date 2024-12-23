# NixOS System Configuration Helper

A Lua-based utility for managing NixOS system configurations, dotfiles, and application installations.

## Features

- Links system configuration files to your personal configuration repository
- Registers new NixOS hosts with proper configuration structure
- Manages Flatpak installations and configurations
- Handles user directory cleanup
- Supports NixOS channel management
- Provides system rebuild automation

## Requirements

- NixOS
- Lua 5.1 or later
- Proper file structure:
  - `/data/$USER/System/` - Your system configuration repository
  - `/data/$USER/System/dotfiles/` - Your dotfiles
  - `/data/$USER/System/hosts/` - Host-specific configurations

## Configuration

Edit `conf.lua` to customize your setup:

```lua
conf = {
    host          = nil,     -- Set to hostname string for new machines
    link_to_home  = false,   -- Link /etc/nixos/configuration.nix to System
    add_unstable  = false,   -- Add nixos-unstable channel
    register_host = false,   -- Create new host configuration
    userconfig    = false,   -- Link dotfiles
    rmdirs        = false,   -- Remove default home directories
    flatpaks      = false,   -- Install configured Flatpaks
    rebuild       = false,   -- Rebuild system after changes
}
```

## Usage

1. Clone your system configuration repository:
```bash
mkdir -p /data/$USER
git clone <your-system-repo> /data/$USER/System
```

2. Run the script:
```bash
lua main.lua
```

### Common Tasks

#### Setting Up a New Machine
```lua
-- In conf.lua:
conf.host = "new-hostname"  -- Set your desired hostname
conf.link_to_home = true    -- Link system configuration
conf.register_host = true   -- Create host configuration
conf.rebuild = true         -- Rebuild system
```

#### Installing Flatpaks
```lua
-- In conf.lua:
conf.flatpaks = true       -- Enable Flatpak installation
```
Edit `conf.flatpak_list` to customize which Flatpaks to install.

#### Managing Home Directory
```lua
-- In conf.lua:
conf.rmdirs = true        -- Remove default directories
```
Edit `conf.dirs_to_remove` to customize which directories to remove.

## Directory Structure

- `main.lua` - Main application logic
- `conf.lua` - Configuration and templates
- `lib.lua` - Helper functions (required but not shown)

## Development Approach

- Configuration-driven functionality
- Clear separation between configuration and logic
- Type checking for critical functions
- Template-based file generation
- Command composition for complex operations

## Warning

⚠️ Be careful with:
- Setting `register_host = true` as it will reset your host configuration
- Setting `rmdirs = true` as it will remove specified home directories
- Running with `rebuild = true` as it will trigger a system rebuild

## License

MIT License

