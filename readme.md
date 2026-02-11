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
mpm intro              Interactive tutorial
mpm install <pkg>      Install package
mpm remove <pkg>       Remove package
mpm update [pkg]       Update packages
mpm search <query>     Search packages
mpm list [remote]      List packages
mpm info <pkg>         Package details
mpm run <pkg>          Run package
mpm startup [pkg]      Set boot package
mpm tap <url>          Add repository
mpm reset [--hard]     Clear packages
mpm doctor             Check health
mpm self_update        Update MPM
mpm help [cmd]         Show help
```

## Quick Start

```bash
mpm intro                    # Interactive tutorial
# or manually:
mpm list remote              # See packages
mpm search display           # Search packages
mpm install displays         # Install
mpm run displays             # Run
mpm startup displays         # Set as boot
```

## Taps

```bash
mpm tap https://pkg.url/     # Add tap
mpm tap --list               # List taps
mpm tap --remove name        # Remove tap
mpm tap --default name       # Set default
mpm install tap/package      # From specific tap
```

## Maintenance

```bash
mpm doctor                   # Check health
mpm reset                    # Clear packages
mpm reset --hard             # Full reset (taps too)
mpm self_update              # Update MPM
```

## Package Structure

```
my-package/
├── manifest.json
├── start.lua
└── lib/utils.lua
```

```json
{
  "name": "my-package",
  "description": "Description",
  "files": ["start.lua", "lib/utils.lua"],
  "dependencies": ["utils"]
}
```

## Creating a Tap

1. Create packages with `manifest.json`
2. Add `index.json`: `[{"name": "pkg", "description": "..."}]`
3. Host on Netlify/GitHub Pages
4. `mpm tap https://your-url/`

## Links

- [Packages](https://shelfwood-mpm-packages.netlify.app/)
- [GitHub](https://github.com/Bitcraft-Creations/mpm)
