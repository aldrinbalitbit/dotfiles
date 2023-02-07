#!/bin/bash -e
green='\x1B[0;32m'
blue='\x1B[0;34m'
white='\x1B[0;37m'
reset='\x1B[0;m'
bold='\x1B[1;m'
success=`printf " ${blue}${bold}[${green}${bold}*${blue}${bold}]${reset}"`
info=`printf " ${blue}${bold}[${white}${bold}i${blue}${bold}]${reset}"`

_process_handlers () {
        echo -e "${bold}Process handlers:${reset}"
        echo -e "${success}: for success"
	echo -e "${info}: for info"
	printf "${bold}Apertis Setup needs 50GB free space for dotfiles to compile binaries and libraries, running ansible tasks, suckless' dwm and dmenu setup and more use.${reset}"
	sleep 5
        echo
}

_download_container () {
	printf "${info}: Downloading apertis image..."
	wget -qO apertis.tar.gz https://images.apertis.org/release/v2022/v2022.3/amd64/isolation-sysroot/isolation_sysroot-v2022-amd64-v2022.3.tar.gz
	echo 
}

_docker_build () {
	printf "${info}: Running docker build..."
	sleep 5
	echo
	docker build .
}

_remove_container () {
	printf "${info}: Removing container..."
	rm apertis.tar.gz
}

_process_handlers
_download_container
_docker_build
_remove_container
echo "${success}: The build has completed on CI."
exit 0
