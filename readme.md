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
| `mpm install <package>` | Install a package |
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

### Repository Management (Taps)

| Command | Description |
|---------|-------------|
| `mpm tap <source>` | Add a package repository |
| `mpm tap --list` | List configured taps |
| `mpm tap --remove <name>` | Remove a tap |
| `mpm tap --default <name>` | Set default tap |
| `mpm untap <name>` | Alias for tap --remove |

### System

| Command | Description |
|---------|-------------|
| `mpm self_update` | Update MPM itself |
| `mpm uninstall` | Completely remove MPM |
| `mpm help [command]` | Show help |

## Taps (Custom Package Repositories)

Taps allow you to add custom package sources. MPM comes with the official tap pre-configured.

### Adding a Tap

```bash
# GitHub shorthand (prompts for hosting URL)
mpm tap j-shelfwood/mpm-packages

# Full GitHub URL
mpm tap https://github.com/j-shelfwood/mpm-packages

# Direct hosting URL (Netlify, custom server, etc.)
mpm tap https://my-packages.netlify.app/
```

### Managing Taps

```bash
# List all configured taps
mpm tap --list

# Remove a tap
mpm tap --remove my-tap
mpm untap my-tap

# Set a tap as default
mpm tap --default my-tap
```

### Installing from a Specific Tap

```bash
# Install from specific tap
mpm install my-tap/package-name

# Install from default tap
mpm install package-name
```

## Usage Examples

Install packages:
```bash
mpm install tools
mpm install views displays utils peripherals
```

Run packages:
```bash
mpm run displays
mpm run tools/inspect_peripheral
```

View available packages from all taps:
```bash
mpm list remote
```

Configure startup:
```bash
mpm startup displays
mpm startup --show
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

## Hosting a Package Repository

To create your own tap:

1. Create a directory structure with packages:
   ```
   my-packages/
   ├── index.json          # Package listing
   ├── package-a/
   │   ├── manifest.json
   │   └── start.lua
   └── package-b/
       ├── manifest.json
       └── lib/utils.lua
   ```

2. Create `index.json` listing your packages:
   ```json
   [
     {"name": "package-a", "description": "Description A"},
     {"name": "package-b", "description": "Description B"}
   ]
   ```

3. Host on Netlify, GitHub Pages, or any static file server

4. Add the tap:
   ```bash
   mpm tap https://your-packages.netlify.app/
   ```

## Loading Dependencies

Within a running package, use the global `mpm()` function to load other packages:

```lua
local AEInterface = mpm('peripherals/AEInterface')
local ae = AEInterface.new()
```

## Configuration Files

| File | Purpose |
|------|---------|
| `/mpm/taps.json` | Configured package repositories |
| `/startup.config` | Startup package configuration |
| `/startup.lua` | Generated boot script |

## Repository

- MPM Core: https://shelfwood-mpm.netlify.app/
- Official Packages: https://shelfwood-mpm-packages.netlify.app/
- GitHub: https://github.com/j-shelfwood/mpm
