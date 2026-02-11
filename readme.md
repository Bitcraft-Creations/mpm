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

After installation, run the interactive tutorial:
```
mpm intro
```

## Commands

```
mpm intro              Interactive tutorial
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
# Interactive tutorial (recommended for new users)
mpm intro

# Or manually:
mpm list remote                           # See packages
mpm install displays views utils          # Install
mpm run displays                          # Run
mpm startup displays                      # Set as boot
```

## Taps

Package repositories:

```bash
mpm tap https://my-packages.netlify.app/  # Add tap
mpm tap --list                            # List taps
mpm tap --remove mytap                    # Remove tap
mpm tap --default mytap                   # Set default
mpm install mytap/package                 # From specific tap
```

## Package Structure

```
my-package/
├── manifest.json
├── start.lua
└── lib/utils.lua
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

## Creating a Tap

1. Create packages with `manifest.json`
2. Add `index.json`:
   ```json
   [{"name": "pkg", "description": "..."}]
   ```
3. Host on Netlify/GitHub Pages
4. `mpm tap https://your-url/`

## Links

- [Official Packages](https://shelfwood-mpm-packages.netlify.app/)
- [GitHub](https://github.com/Bitcraft-Creations/mpm)
