#!/bin/bash

distro_update() { 
	apt-get update && 
	apt-get upgrade
}

distro_install() {
	apt-get -y install $@
}

distro_description() {
	apt-cache show $1 2>/dev/null | grep -m 1 -E "^Description" | cut -d ' ' -f 2-
}
