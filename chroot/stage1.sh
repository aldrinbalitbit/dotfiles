#!/bin/sh -e

ls /usr/lib/x86_64-linux-gnu

echo "Updating apertis repositories..."
echo "deb https://repositories.apertis.org/apertis/ v2024dev1 development sdk target" > /etc/apt/sources.list
apt-get -qqy update
echo "Uninstalling systemd..."
apt-get -qqy remove --purge --autoremove --allow-remove-essential systemd systemd-sysv
echo "Upgrading Apertis..."
apt-get -qqy upgrade
echo "Installing build dependencies..."
apt-get -qqy install gcc make g++ ca-certificates wget

# Compile tzdata dependencies
# Compile ncurses
echo "Compiling ncurses..."
wget -qO- https://github.com/ThomasDickey/ncurses-snapshots/archive/refs/heads/master.tar.gz | tar -zxf- -C /sources/
mv /sources/ncurses-snapshots-master /sources/ncurses && cd /sources/ncurses
_ncurses_version=6.4
./configure --prefix=/usr \
	    --libdir=/usr/lib/x86_64-linux-gnu \
	    --mandir=/usr/share/man \
	    --enable-pc-files \
	    --enable-widec \
	    --with-cxx-shared \
	    --with-pkg-config-libdir=/usr/lib/x86_64-linux-gnu/pkgconfig \
	    --with-shared \
	    --with-versioned-syms \
	    --with-xterm-kbs=del \
	    --with-ada \
	    --without-debug
make
make install
install -Dm644 COPYING -t /usr/share/licenses/ncurses
for lib in ncurses ncurses++ form panel menu; do
	printf "INPUT(-l%sw)\n" "${lib}" > "/usr/lib/x86_64-linux-gnu/lib${lib}.so"
	ln -sv ${lib}w.pc "/usr/lib/x86_64-linux-gnu/pkgconfig/${lib}.pc"
done
printf 'INPUT(-lncursesw)\n' > "/usr/lib/x86_64-linux-gnu/libcursesw.so"
ln -sv libncurses.so "/lib/x86_64-linux-gnu/libcurses.so"
for lib in tic tinfo; do
	printf "INPUT(libncursesw.so.%s)\n" "${_ncurses_version:0:1}" > "/usr/lib/x86_64-linux-gnu/lib${lib}.so"
	ln -sv libncursesw.so.${_ncurses_version:0:1} "/usr/lib/x86_64-linux-gnu/lib${lib}.so.${_ncurses_version:0:1}"
	ln -sv ncursesw.pc "/usr/lib/x86_64-linux-gnu/pkgconfig/${lib}.pc"
done
# Compile readline
echo "Compiling readline..."
wget -qO- https://git.sv.gnu.org/cgit/readline.git/snapshot/readline-master.tar.gz | tar -zxf- -C /sources/
mv /sources/readline-master /sources/readline && cd /sources/readline
wget -qO- https://ftp.gnu.org/gnu/readline/readline-8.2-patches/readline82-001 | patch -p0 -i-
./configure --prefix=/usr \
	    --libdir=/usr/lib/x86_64-linux-gnu \
	    CFLAGS="$CFLAGS -fPIC"
make SHLIB_LIBS=-lncurses
# Compile bash
echo "Compiling bash..."
wget -qO- https://git.sv.gnu.org/cgit/bash.git/snapshot/bash-master.tar.gz | tar -zxf- -C /sources/
mv /sources/bash-master /sources/bash && cd /sources/bash
_bash_opts=(-DDEFAULT_PATH_VALUE=\'\"/usr/local/sbin:/usr/local/bin:/usr/bin\"\'
            -DSTANDARD_UTILS_PATH=\'\"/usr/bin\"\'
            -DSYS_BASHRC=\'\"/etc/bash.bashrc\"\'
            -DSYS_BASH_LOGOUT=\'\"/etc/bash.bash_logout\"\'
            -DNON_INTERACTIVE_LOGIN_SHELLS)
./configure --prefix=/usr \
	    --with-curses \
	    --enable-readline \
	    --with-installed-readline \
	    CFLAGS="${CFLAGS} ${_bashopts[@]}"
make
make install
# Compile tzdata
echo "Compiling tzdata..."
mkdir /sources/tzdb && cd /sources/tzdb
wget -qO- https://www.iana.org/time-zones/repository/tzcode-latest.tar.gz | tar -zxf-
wget -qO- https://www.iana.org/time-zones/repository/tzdata-latest.tar.gz | tar -zxf-
make LFLAGS="${LDFLAGS} ${LTOFLAGS}"
make install
