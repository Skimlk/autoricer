#!/bin/bash
package_list="packagelist.yaml"

#Distro-specific Functions
update() { 
	apt-get update && 
	apt-get upgrade
}
install() {
	apt-get -y install $@ 
}
description() {
	desc=$(apt-cache show $1 2>/dev/null | grep -m 1 -E "^Description" | cut -d ' ' -f 2-)
	if [ -z "$desc" ]; then
		echo "No description available"
	else
		echo "$desc"
	fi
}

#Script Start
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

update

#Install Dependencies
install whiptail yq

#Install Packages
selected_packages=()
for group in $(yq -r 'keys | reverse | .[]' $package_list)
do
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

#Configure and Install Packages
source customsetup.sh
for package in ${selected_packages[@]}; do
	#Install Package
	if declare -f install_$package > /dev/null; then
		install_$package
	else
		install $package
	fi	

	#Configure Package
	if declare -f configure_$package > /dev/null; then
   		echo "Configuring '$package'"
		configure_$package
	fi
done

exit 0
