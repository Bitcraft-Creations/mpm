# Minecraft Package Manager (MPM)

MPM is a package manager for Minecraft's ComputerCraft mod. It allows you to manage scripts and utilities across your in-game computers, directly pulling from GitHub repositories.

## Installation

1. Use the Pastebin `get` command to download the `install.lua` file to your in-game computer. Replace `pastebin_link` with the link to your Pastebin.

   ```
   pastebin get https://pastebin.com/X6t1t0fY install.lua
   ```

2. Run the `install.lua` script. This will download the necessary package manager files from this repository to your in-game computer.

   ```
   install
   ```

3. During installation, you'll be asked if you want to add the default package repository. This repository contains a number of handy utilities. Enter `yes` to add this repository.

## Usage

Once installed, you'll have access to the following commands:

- `mpm.tap_repository('url')`: This function allows you to add a new repository to the list of tapped repositories.
- `mpm.install('package')`: Use this function to install a package from the available repositories.
- `mpm.update('package')`: This function updates an already installed package.
- `mpm.remove('package')`: This function allows you to remove a package.
- `mpm.list()`: This function lists all installed packages.
- `mpm.available()`: This function lists all available packages from the tapped repositories.

Replace `'url'` and `'package'` with the URL of the repository or the name of the package respectively.

For example, to install a package called `my_package`, you would use the command `mpm.install('my_package')`.

## Contributing

You're welcome to contribute to MPM. Feel free to submit a Pull Request or open an issue if you have any ideas or run into any issues.

---

Feel free to modify this README to better suit your needs.
