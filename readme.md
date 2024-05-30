# MPM - Minecraft Package Manager

MPM is a package manager for Minecraft's ComputerCraft ([CC:Tweaked](https://tweaked.cc)) mod. Designed to work on CraftOS, it allows you to easily install, update and execute scripts and utilities.

## Installation

Run the following command to install MPM on your in-game computer:

```bash
wget run https://shelfwood-mpm.netlify.app/install.lua
```

## Usage

Once MPM is installed, you can use the following commands:

- `mpm install <package>`: Install a module containing lua scripts
- `mpm update [package]`: Update a specific module or all modules if no package name is provided.
- `mpm remove <package>`: Remove a specific module.
- `mpm startup`: Setup a module package script as startup script
- `mpm list`: List all installed modules.
- `mpm run <package>`: Run a specific module.
- `mpm self_update`: Update MPM

For instance, to install a package named `my_package`, you would use:

```bash
mpm install tools
```

You could then run a script from the recently installed `tools` module using:

```bash
mpm run tools/inspect_peripheral
```

Some modules might have dependencies, you can install multiple modules at once:

```bash
mpm install views displays utils peripherals
```

For example you could set-up multiple monitors to show information from peripherals in your network by running the `displays/setup` script:

```bash
mpm run displays/setup
```

## Features in development

- Tapping your own GitHub repository for modules to install
- Automatically installing any dependencies for modules you are installing

## Contributing

Contributions to MPM are welcomed. Feel free to submit a Pull Request or open an issue if you have any ideas or encounter any problems.
