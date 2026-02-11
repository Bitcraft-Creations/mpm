# MPM

```
 __  __ ___ __  __
|  \/  | _ \  \/  |
| |\/| |  _/ |\/| |
|_|  |_|_| |_|  |_|
```

Package manager for [CC:Tweaked](https://tweaked.cc) computers in Minecraft.

## Install

```
wget run https://shelfwood-mpm.netlify.app/install.lua
```

## Commands

```
mpm install <pkg>      Install package
mpm remove <pkg>       Remove package
mpm update [pkg]       Update packages
mpm list [remote]      List packages
mpm info <pkg>         Package details
mpm run <pkg>          Run package
mpm startup [pkg]      Set boot package
mpm tap <url>          Add repository
mpm self_update        Update MPM
mpm help [cmd]         Show help
```

## Quick Start

```bash
# See available packages
mpm list remote

# Install packages
mpm install displays views utils peripherals

# Run a package
mpm run displays

# Set startup package
mpm startup displays
```

## Taps

Add custom package repositories:

```bash
# Direct URL
mpm tap https://my-packages.netlify.app/

# Manage taps
mpm tap --list
mpm tap --remove mytap
mpm tap --default mytap

# Install from specific tap
mpm install mytap/package
```

## Package Structure

```
my-package/
├── manifest.json
├── start.lua
└── lib/
    └── utils.lua
```

**manifest.json:**
```json
{
  "name": "my-package",
  "description": "Description",
  "files": ["start.lua", "lib/utils.lua"],
  "dependencies": ["utils"]
}
```

## Loading Dependencies

```lua
local AEInterface = mpm('peripherals/AEInterface')
```

## Creating a Tap

1. Create packages with `manifest.json`
2. Add `index.json` listing packages:
   ```json
   [{"name": "pkg", "description": "..."}]
   ```
3. Host on Netlify/GitHub Pages
4. `mpm tap https://your-url/`

## Links

- [Official Packages](https://shelfwood-mpm-packages.netlify.app/)
- [GitHub](https://github.com/Bitcraft-Creations/mpm)
