#!/bin/bash

source /etc/os-release
source ./distro-specific-functions/*$ID*.sh
package_list="packagelist.yaml"

description() {
	desc=$(distro_description $1)
	if [ -z "$desc" ]; then
		echo "No description available"
	else
		echo "$desc"
	fi
}

install() {
	for package in "$@"; do
		echo "Installing '$package'"
		if declare -f install_$package > /dev/null; then
			install_$package
		else
			distro_install $package 
		fi
	done
}

configure() {
	echo "Configuring '$1'"
	if declare -f configure_$1 > /dev/null; then
		echo "Configuring '$1'"
		configure_$1
	fi
}

setup() {
	for package in "$@"; do
		echo "Setting up '$package'"
		install $package
		configure $package
	done
}

rice() {
	#Install Dependencies
	install whiptail yq

	#Install Packages
	selected_packages=()
	for group in $(yq -r 'keys | reverse | .[]' $package_list); do
		if whiptail \
			--title "Install Packages" \
			--yesno "Would you like to install $group packages?" 8 78; 
		then	
			options=()
			for package in $(yq -r ".$group | .[]" $package_list); do
				options+=("$package" "$(description $package)" "ON")
			done

			selected_packages+=( $(whiptail --title "Install $group Packages" --checklist \
				"Select which packages you would like to install" 20 100 15 \
				"${options[@]}" 3>&1 1>&2 2>&3 | tr -d '"') )
		fi
	done

	setup ${selected_packages[@]}
}

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

source customsetup.sh

if [ "$1" = "install" ]; then
	setup ${@:2}
else
	rice
fi

exit 0
