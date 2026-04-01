# autoricer
 
A shell script for automating Linux system setup and package installation with a TUI-based selection interface.
 
## What it does
 
autoricer reads a `packagelist.yaml` file, presents an interactive checklist (via `whiptail`) for selecting which packages to install, then installs and configures each selected package. Package groups are presented one at a time so you can opt in or out of entire categories.
 
Custom `install_<package>` and `configure_<package>` functions can be defined in `customsetup.sh` for each package and get called in place of the package manager. Distro-specific package management functionality can be added.
 
## Requirements
 
- Bash
- `whiptail`
- `yq`
- Must be run as root
 
## Usage
 
**Interactive mode** — presents the full TUI package selector:
 
```bash
sudo ./autoricer.sh
```
 
**Direct install** — installs and configures specific packages without the TUI:
 
```bash
sudo ./autoricer.sh install <package1> <package2> ...
```
 
## Structure
 
```
autoricer/
├── autoricer.sh                  # Main script
├── packagelist.yaml              # Package groups and entries
├── customsetup.sh                # Optional custom setup logic (sourced at runtime)
└── distro-specific-functions/
    └── <distro-id>.sh            # Distro-specific package management functions
```
 
The distro is detected automatically from `/etc/os-release`. The corresponding script in `distro-specific-functions/` is sourced based on the `$ID` variable.
 
## Customization
 
**Adding packages** — add entries to `packagelist.yaml` under the appropriate group.
 
**Package-specific behavior** — define `install_<package>` or `configure_<package>` functions in `customsetup.sh`. If those functions don't exist, the script falls back to `distro_install`.
 
**Distro-specific behavior** — define package management functions in your distro's file under `distro-specific-functions/`.
 
**Custom setup** — put anything extra in `customsetup.sh` at the repo root; it gets sourced before anything runs.

## Setup
 
`packagelist.yaml` and `customsetup.sh` are not included — you need to create them yourself. The following are examples.
 
**packagelist.yaml**
 
```yaml
Main:
    - firefox
    - alacritty
WM:
    - i3
```
 
**customsetup.sh**
 
```bash
install_i3() {
    git clone https://github.com/i3/i3 && cd i3 && make install && cd ..
}
 
configure_alacritty() {
    cp dotfiles/alacritty.toml ~/.config/alacritty/alacritty.toml
}
```

## Supported distros
 
Depends on what's present in `distro-specific-functions/`. Add a new `<distro-id>.sh` file there to support additional distros.
