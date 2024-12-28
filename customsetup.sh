#!/bin/bash
git clone https://github.com/Skimlk/dotfiles
dotfiles="$(basename $_)" 

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
    install signal

    rm signal-desktop-keyring.gpg
}

#Application Configurations
configure_i3() {
	cp $dotfiles/i3/config ~/.config/i3/
	cp $dotfiles/i3/i3status.conf /etc/
}
configure_obs() {
    #Virtual Camera
    install v4l2loopback-dkms
}
configure_lxterminal() {
	install fortune-mod fortune-debian-hints cowsay
}

#Other Configurations

