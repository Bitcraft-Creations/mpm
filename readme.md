# MPM - Minecraft Package Manager

MPM is a package manager for Minecraft's ComputerCraft ([CC:Tweaked](https://tweaked.cc)) mod. Designed to work on CraftOS, it allows you to easily install, update and execute scripts and utilities.

## Installation

Run the following command to install MPM on your in-game computer:

```bash
wget run https://shelfwood-mpm.netlify.app/install.lua
```

## Commands

### Package Management

| Command | Description |
|---------|-------------|
| `mpm install <package>` | Install a package from the registry |
| `mpm remove <package>` | Remove an installed package |
| `mpm update [package]` | Update specific or all packages |
| `mpm list [local\|remote]` | List installed or available packages |
| `mpm info <package>` | Show package details |

### Running Packages

| Command | Description |
|---------|-------------|
| `mpm run <package>` | Run a package's start.lua |
| `mpm run <package/script>` | Run a specific script |
| `mpm startup [package]` | Set package to run on boot |

### System

| Command | Description |
|---------|-------------|
| `mpm self_update` | Update MPM itself |
| `mpm uninstall` | Completely remove MPM |
| `mpm help [command]` | Show help |

## Usage Examples

Install a single package:
```bash
mpm install tools
```

Install multiple packages:
```bash
mpm install views displays utils peripherals
```

Run a package:
```bash
mpm run displays
```

Run a specific script within a package:
```bash
mpm run tools/inspect_peripheral
```

View available packages:
```bash
mpm list remote
```

View installed packages with descriptions:
```bash
mpm list
```

Get package info before installing:
```bash
mpm info displays
```

Set a package to run on computer startup:
```bash
mpm startup displays
```

Update all packages:
```bash
mpm update
```

Completely remove MPM:
```bash
mpm uninstall
```

## Package Structure

Packages are stored in `/mpm/Packages/<package-name>/` and contain:

- `manifest.json` - Package metadata
- `start.lua` - Entry point (optional)
- Additional Lua files

### Manifest Format

```json
{
  "name": "my-package",
  "description": "A description of the package",
  "version": "1.0.0",
  "author": "Your Name",
  "files": [
    "start.lua",
    "lib/utils.lua"
  ],
  "dependencies": [
    "utils"
  ]
}
```

## Loading Dependencies

Within a running package, use the global `mpm()` function to load other packages:

```lua
-- Load a package
local AEInterface = mpm('peripherals/AEInterface')

-- Use it
local ae = AEInterface.new()
```

## Contributing

Contributions to MPM are welcomed. Feel free to submit a Pull Request or open an issue if you have any ideas or encounter any problems.

## Repository

- MPM Core: https://shelfwood-mpm.netlify.app/
- Package Registry: https://shelfwood-mpm-packages.netlify.app/
