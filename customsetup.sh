#!/bin/bash
git clone https://github.com/Skimlk/dotfiles
dotfiles="$(basename $_)" 
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)

#Application Installations
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
	cp $dotfiles/i3/config $USER_HOME/.config/i3/
	cp $dotfiles/i3/i3status.conf /etc/
	cp $dotfiles/.xbindkeysrc $USER_HOME/
	mkdir -p $USER_HOME/Pictures/wallpapers
	wget https://files.catbox.moe/4qepc1.png -O $USER_HOME/Pictures/wallpapers/forest.png
}
configure_vim() {
	cp $dotfiles/.vimrc $USER_HOME/
}
configure_obs() {
    #Virtual Camera
    install v4l2loopback-dkms
}
configure_lxterminal() {
	install fortunes fortune-mod fortunes-debian-hints cowsay
	cp $dotfiles/lxterminal.conf $USER_HOME/.config/lxterminal/
	mkdir -p $USER_HOME/.local/share/fonts/
	wget https://files.catbox.moe/p60y2w.otf -O $USER_HOME/.local/share/fonts/ComicCode-Regular.otf
	fc-cache
}

#Other Configurations
cp $dotfiles/.bashrc $USER_HOME/
