#!/bin/sh -e
source "$(curl -sL https://github.com/aldrinbalitbit/dotfiles/raw/main/common.sh)"
_banner

if [[ "${_os}" == "GNU/Linux" ]] || [[ "$(uname -s)Darwin" == "Darwin" ]]; then
    _check_root
elif [[ "${_os}" == "Android" ]]; then
    _msg "OS "
fi


git clone --depth=1 https://github.com/aldrinbalitbit/dotfiles.git "${_dotfiles_dir}"
