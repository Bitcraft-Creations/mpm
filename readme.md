# Minecraft Package Manager (MPM)

MPM is a package manager for Minecraft's ComputerCraft mod. With MPM, you can easily manage and update scripts and utilities across your in-game computers, pulling directly from GitHub repositories.

## Installation

1. Download the `install.lua` file to your in-game computer using the Pastebin `get` command. Replace `pastebin_link` with the link to the Pastebin.

   ```
   pastebin get https://pastebin.com/g6nYAkRT install.lua
   ```

2. Run the `install.lua` script to install MPM. This script will automatically download the necessary package manager files from the MPM GitHub repository.

   ```
   install
   ```

3. During installation, you will be prompted to add the default package repository. This repository contains a variety of useful packages. To add this repository, simply enter `yes` when prompted.

## Usage

Once MPM is installed, you can use the following commands:

- `mpm tap_repository <repository url>`: Add a new repository to your list of tapped repositories.
- `mpm install <package>`: Install a package from the tapped repositories.
- `mpm update [package]`: Update a specific package or all packages if no package name is provided.
- `mpm remove <package>`: Remove a specific package.
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
