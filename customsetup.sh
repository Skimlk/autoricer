#!/bin/bash

init() {
	autoricer_dir=$(pwd)
	git clone https://github.com/Skimlk/dotfiles || (
		cd dotfiles && git pull
	)
	echo "$autoricer_dir"
	cd "$autoricer_dir"

	syncfiles="dotfiles/sync-files.sh"	
	chmod +x "$syncfiles"

	dotfiles="$(basename $_)" 
	USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)

	$syncfiles push bash
}

#Application Installations
install_librewolf() {
	install extrepo
	extrepo enable librewolf
	update 
	install librewolf
}
install_signal() {
    # 1. Install our official public software signing key:
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

    # 2. Add our repository to your list of repositories:
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
        sudo tee /etc/apt/sources.list.d/signal-xenial.list

    # 3. Update your package database and install Signal:   
    update
    install signal-desktop

    rm signal-desktop-keyring.gpg
}
install_steam() {
	install gawk
	wget https://cdn.fastly.steamstatic.com/client/installer/steam.deb
	dpkg --skip-same-version -i steam.deb
	rm steam.deb
	gawk -i inplace '
	/# Don'\''t allow running as root/ { 
		found = 1 
	} 
	found && /exit 1/ { 
		sub(/^exit 1/, "# &"); 
		found = 0 
	} 
	{ print }' /bin/steam
}
install_minecraft() {
	wget https://launcher.mojang.com/download/Minecraft.deb
	dpkg --skip-same-version -i Minecraft.deb
	rm Minecraft.deb
}
install_srb2k() {
	install flatpak
	flatpak install flathub org.srb2.SRB2Kart
}

#Application Configurations
configure_i3() {
	install xorg xbindkeys xwallpaper #Setup Wallpaper
	$syncfiles push i3
	$syncfiles push xbindkeys

	mkdir -p $USER_HOME/Pictures/wallpapers
	wget https://files.catbox.moe/4qepc1.png -O $USER_HOME/Pictures/wallpapers/forest.png
}
configure_vim() {
	$syncfiles push vim
}
configure_obs() {
    #Virtual Camera
    install v4l2loopback-dkms
}
configure_lxterminal() {
	install fortunes fortune-mod fortunes-debian-hints cowsay
	$syncfiles push lxterminal
	mkdir -p $USER_HOME/.local/share/fonts/
	wget https://files.catbox.moe/p60y2w.otf -O $USER_HOME/.local/share/fonts/ComicCode-Regular.otf
	fc-cache
}

init
