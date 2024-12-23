# NixOS Configuration

A modular NixOS configuration focused on GNOME desktop environment with development tools and multimedia applications.

## Features

- GNOME desktop environment with custom extensions
- Development tools (VS Code, GNOME Builder, Git)
- Multimedia applications (Darktable, GIMP, Inkscape, etc.)
- Docker and VirtualBox support
- Printer support with CUPS
- PipeWire audio system
- Custom system management script
- Multi-host configuration management

## Structure

```
.
├── config.nix          # Main shared configuration
├── hosts/             # Host-specific configurations
│   ├── box/          # Server configuration
│   │   ├── config.nix
│   │   └── hardware.nix
│   ├── macbook/      # MacBook configuration
│   ├── ThinkPad/     # ThinkPad configuration
│   └── x280/         # X280 configuration
├── setup/             # Setup system
│   ├── shell.nix     # Development environment
│   ├── install       # Installation script
│   └── pkgs/        # Local packages
├── scripts/          # System management scripts
│   ├── system.nix    # Main system management script
│   └── server.nix    # Server-specific management
├── pkgs/            # Custom package definitions
│   └── offtree.nix  # Additional package configurations
└── dotfiles/        # Application configurations
    ├── builder/     # GNOME Builder settings
    ├── darktable/  # Darktable presets
    └── thunderbird/ # Thunderbird settings
```

## Host Management

The configuration supports multiple hosts with different roles:

### Server Configuration (box)
- Docker support with custom data root
- OpenSSH server
- Configured port ranges
- Server-specific storage bindings

### Laptop Configurations
- Desktop environment optimizations
- Hardware-specific settings
- Power management
- User-specific configurations

### Adding New Hosts

1. Register a new host using the setup tool:
```bash
system -s
# Follow prompts to register new host
```

2. The system will:
   - Create host directory structure
   - Copy hardware configuration
   - Generate host-specific config.nix
   - Set hostname and system version

## Setup System

The setup system is a Lua-based configuration tool that helps manage the NixOS installation:

### Installation

1. Download and run the install script:
```bash
wget https://raw.githubusercontent.com/burij/nixcnfg/main/install
chmod +x install
./install
```

2. The script will:
   - Download the configuration
   - Set up the development environment
   - Launch the setup tool

### Setup Tool Features

- System configuration management
- Host registration and configuration
- Dotfiles deployment
- Application settings restoration
- Development environment setup

### System Management

The `system` script provides several management commands:

```bash
system -u    # rebuild and upgrade all packages
system -a    # rebuild without upgrading
system -s    # run system setup tool
system -e    # open system configuration in GNOME Builder
system -c    # run upgrade check
system -p    # purge old generations and unused flatpaks
system -b    # backup application settings
```

## Maintenance

Regular system maintenance:

1. Update and rebuild:
```bash
system -u
```

2. Clean old generations:
```bash
system -p
```

3. Backup settings:
```bash
system -b
```

## Requirements

- NixOS installation
- GNOME desktop environment
- Git
- wget
- Basic Lua support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - See LICENSE file for details

## Acknowledgments

- NixOS community
- GNOME project
- Various open source projects included in the configuration

## Support

Create an issue in the repository for:
- Bug reports
- Feature requests
- Configuration help

## Configuration

### Main System Configuration (config.nix)

The main configuration includes:
- System packages
- User settings
- Desktop environment configuration
- Service enablement
- Hardware configuration
- Boot settings
- File system bindings

### Host-Specific Configuration

Each host has its own configuration in the `hosts/` directory:
- Hardware-specific settings
- Role-based configurations (server/desktop)
- Custom filesystem bindings
- Service configurations

### Development Environment

A Nix shell environment (shell.nix) provides:
- Lua development tools
- Build utilities
- Testing frameworks

### Application Settings

Dotfiles are organized by application:
- GNOME Builder keyboard shortcuts and preferences
- Darktable presets and lua scripts
- Thunderbird settings

## Customization

1. Fork this repository
2. Register your host:
   ```bash
   system -s
   # Follow prompts to register new host
   ```

3. Modify host config.nix for your system:
   - Adjust package list
   - Configure users
   - Set locale and timezone
   - Configure file system bindings

4. Update setup/conf.lua with your preferences:
   - Set paths
   - Configure backup locations
   - Adjust application settings

5. Run the setup tool:
```bash
system -s
```

