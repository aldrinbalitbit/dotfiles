#!/bin/sh -e
source "${_cur_dir}"/common.sh

_banner

if _check_cmd apk; then
    _pkg_mgr="apk add"
elif _check_cmd apt-get; then
    _pkg_mgr="apt-get -y install"
elif _check_cmd brew; then
    _pkg_mgr="brew install"
elif _check_cmd dnf; then
    _pkg_mgr="dnf install"
elif _check_cmd emerge; then
        _pkg_mgr="emerge -uDNvt"
    elif _check_cmd eopkg; then
        _pkg_mgr="eopkg install"
    elif _check_cmd pacman; then
        _pkg_mgr="pacman -Syyuu"
    elif _check_cmd urpmi; then
        _pkg_mgr="urpmi"
    elif _check_cmd xbps-install; then
        _pkg_mgr="xbps-install"
    elif _check_cmd zypper; then
        _pkg_mgr="zypper in"
    else
        _msg ""
    fi

_bash_cmd="`command -v bash`"
if _check_cmd bash; then
    _msg "Bash found in your PATH: ${_bash_cmd}"
else
    _err "Bash not found in your PATH."
    _err ""
    _err "Please install bash in your package manager and try again:"
    _err "    ${_pkg_mgr} bash"
fi


