# Minecraft Package Manager (MPM)

MPM is a package manager for Minecraft's ComputerCraft mod. With MPM, you can easily manage and update scripts and utilities across your in-game computers, pulling directly from GitHub repositories.

## Installation

Download the `install.lua` file to your in-game computer using the Pastebin `get` command. Replace `pastebin_link` with the link to the Pastebin.

```
wget run https://shelfwood-mpm.netlify.app/install.lua
```

## Usage

Once MPM is installed, you can use the following commands:

- `mpm install <package>`: Install a package from the tapped repositories.
- `mpm update [package]`: Update a specific package or all packages if no package name is provided.
- `mpm remove <package>`: Remove a specific package.
- `mpm startup`: Setup a package script as startup script
- `mpm list`: List all installed packages.
- `mpm run <package>`: Run a specific package.
- `mpm self_update`: Update the MPM system itself.

For instance, to install a package named `my_package`, you would use the command `mpm install my_package`.

## Contributing

Contributions to MPM are welcomed. Feel free to submit a Pull Request or open an issue if you have any ideas or encounter any problems.

## Updates:

- Installation process now automatically deletes `install.lua` after completion.
- Running just `mpm` now displays the list of available commands.
- Fixed the issue with `mpm` not being globally accessible from the terminal.
- Introduced `mpm self_update` command to keep MPM up to date.
- `mpm update` now allows updating all packages when no package name is provided.
