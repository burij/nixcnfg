# NixOS Configuration Manager

A modular NixOS configuration system with a Lua-based management tool, focused on GNOME desktop environment with development tools and multimedia applications.

WARNING: Do not apply or run these scripts on a production system, as it may result in a broken NixOS installation. This repository is intended to serve as a reference for creating your own configuration, not as a production-ready solution.

## Features

- Interactive system management tool
- Multi-host configuration support
- Automated system setup and maintenance
- Dotfiles management
- Flatpak integration
- Development environment configuration
- Application-specific settings management
- Server administration tools

## Structure

```
.
├── config.nix          # Main shared configuration
├── hosts/             # Host-specific configurations
│   ├── box/          # Server configuration
│   │   ├── config.nix
│   │   └── hardware.nix
│   └── [other-hosts]/  # Additional host configs
├── setup/             # Setup system
│   ├── main.lua      # Main management tool
│   ├── conf.lua      # Configuration settings
│   ├── lib.lua       # Helper functions
│   └── dotfiles.lua  # Dotfiles manager
├── scripts/          # System management scripts
└── dotfiles/        # Application configurations
```

## Quick Start

1. Clone the repository:
```bash
mkdir -p /data/$USER
git clone <your-repo-url> /data/$USER/System
```

2. Configure settings in `setup/conf.lua`:
```lua
conf = {
    host          = nil,     # Set hostname for new machines
    link_to_home  = false,   # Link system configuration
    add_unstable  = false,   # Add unstable channel
    register_host = false,   # Create new host configuration
    userconfig    = true,    # Link dotfiles
    rmdirs        = true,    # Remove default directories
    flatpaks      = true,    # Install configured Flatpaks
    rebuild       = true     # Rebuild system after changes
}
```

3. Run the management tool:
```bash
cd setup
nix-shell
lua main.lua
```

## Management Tool

The interactive management tool provides the following functions:

- System updates and rebuilds
- Host configuration management
- Dotfiles linking and export
- Server administration
- Configuration editing
- Flatpak management
- System maintenance

### Common Commands

```bash
system    # Run the management TUI, if the configuration is active
```

## Host Configuration

Each host maintains its own configuration in `hosts/<hostname>/`:

- Hardware-specific settings
- Role-based configurations
- Service settings
- Package selections
- User configurations

### Adding a New Host

1. Set in conf.lua:
```lua
conf.host = "new-hostname"
conf.register_host = true
conf.rebuild = true
```

2. Run the setup tool and follow the prompts

## Dotfiles Management

The system manages dotfiles through symbolic links:

1. Store dotfiles in `/data/$USER/System/dotfiles/`
2. Configure paths in `index.lua` (inside dotfiles)
3. Use the setup tool to link/export dotfiles

## Server Administration

For server configurations:

- Docker container management
- Service deployment
- Backup handling
- Security settings
- Storage management

## Requirements

- NixOS installation
- Lua 5.1 or later
- Git
- GNOME desktop environment (for desktop configurations)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

Create an issue for:
- Bug reports
- Feature requests
- Configuration help