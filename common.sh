# Variables
_cur_dir="`pwd`"
_os="$(uname -o)"
_dotfiles_dir="${HOME}/.dotfiles"


# Functions
_echo() {
    echo -e "${1}"
}

_banner() {
    _echo "\e[1m/\/                _      _          \e[m"
    _echo "\e[1m     / |          | | o  | |         \e[m"
    _echo "\e[1m    /__|   __ _|_ | |    | |  _   ,  \e[m"
    _echo "\e[1m   //  |  /  \_|  |/  |  |/  |/  / \_\e[m"
    _echo "\e[1m  /o\_/|_/\__/ |_/|__/|_/|__/|__/ \/ \e[m"
    _echo "\e[1m                  |\                 \e[m"
    _echo "\e[1m                  |/                 \e[m"
    _echo "\e[1m Made by: Aldrin Morris D. Balitbit  \e[m"
}

_msg() {
    _echo "\e[1;32m>>\e[m ${1}"
}

_err() {
    _echo "\e[1;31m>>\e[m ${1}"
}

_warn() {
    _echo "\e[1;33m>>\e[m ${1}"
}

_check_cmd() {
    command -v "${1}" &> /dev/null 2>&1
}

_check_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "$me script must be run as root" 1>&2
        exit 1
    fi
}
