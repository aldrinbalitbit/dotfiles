#!/bin/sh -e
echo "Updating apertis repositories..."
echo "deb https://repositories.apertis.org/apertis/ v2024dev1 development sdk target" > /etc/apt/sources.list
apt-get -qqy update
echo "Upgrading Apertis..."
apt-get -qqy upgrade
echo "Uninstalling systemd..."
apt-get -qqy remove --purge --autoremove --allow-remove-essential systemd*
echo "Installing build dependencies..."
apt-get -qqy install gcc make g++ ca-certificates wget bash libreadline-dev

# tzdata
# Compile tzdata dependencies
# Compile ncurses
echo "Compiling ncurses..."
wget -qO- http://github.com/ThomasDickey/ncurses-snapshots/archive/refs/heads/master.tar.gz | tar -zxf- -C /sources/
mv /sources/ncurses-snapshots-master /sources/ncurses && cd /sources/ncurses
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
	    --without-debug \
	    --silent
make --silent
make --silent install
install -Dm644 COPYING -t /usr/share/licenses/ncurses
for lib in ncurses ncurses++ form panel menu; do
	printf "INPUT(-l%sw)\n" "${lib}" > "/usr/lib/x86_64-linux-gnu/lib${lib}.so"
	# ln -sv ${lib}w.pc "/usr/lib/x86_64-linux-gnu/pkgconfig/${lib}.pc"
done
printf 'INPUT(-lncursesw)\n' > "/usr/lib/x86_64-linux-gnu/libcursesw.so"
# ln -sv libncurses.so "/usr/lib/x86_64-linux-gnu/libcurses.so"
for lib in tic tinfo; do
	printf "INPUT(libncursesw.so.6)\n" > "/usr/lib/x86_64-linux-gnu/lib${lib}.so"
	# ln -sv libncursesw.so.6 "/usr/lib/lib${lib}.so.6"
	# ln -sv ncursesw.pc "/usr/lib/x86_64-linux-gnu/pkgconfig/${lib}.pc"
done
# Compile readline
echo "Compiling readline..."
wget -qO- http://git.sv.gnu.org/cgit/readline.git/snapshot/readline-master.tar.gz | tar -zxf- -C /sources/
mv /sources/readline-master /sources/readline && cd /sources/readline
./configure --prefix=/usr \
	    --libdir=/usr/lib/x86_64-linux-gnu \
	    --silent \
	    CFLAGS="$CFLAGS -fPIC"
make --silent SHLIB_LIBS=-lncurses
make --silent install
# Compile bash
echo "Compiling bash..."
wget -qO- http://git.sv.gnu.org/cgit/bash.git/snapshot/bash-master.tar.gz | tar -zxf- -C /sources/
mv /sources/bash-master /sources/bash && cd /sources/bash
./configure --prefix=/usr \
	    --with-curses \
	    --enable-readline \
	    --with-installed-readline \
	    --silent \
	    CFLAGS="${CFLAGS} -DDEFAULT_PATH_VALUE=\'\"/usr/local/games:/usr/local/sbin:/usr/local/bin:/usr/games:/usr/sbin:/usr/bin:/bin:/sbin\"\' -DSTANDARD_UTILS_PATH=\'\"/usr/bin\"\' -DSYS_BASHRC=\'\"/etc/bash.bashrc\"\' -DSYS_BASH_LOGOUT=\'\"/etc/bash.bash_logout\"\' -DNON_INTERACTIVE_LOGIN_SHELLS"
make --silent
make --silent install
# Compile tzdata
echo "Compiling tzdata..."
mkdir /sources/tzdb && cd /sources/tzdb
wget -qO- https://www.iana.org/time-zones/repository/tzcode-latest.tar.gz | tar -zxf-
wget -qO- https://www.iana.org/time-zones/repository/tzdata-latest.tar.gz | tar -zxf-
make --silent LFLAGS="${LDFLAGS} ${LTOFLAGS}"
make --silent install

# Compile rsync dependencies
# Compile attr
echo "Compiling attr..."
wget -qO- http://git.savannah.gnu.org/cgit/attr.git/snapshot/attr-master.tar.gz | tar -zxf- -C /sources/
mv /sources/attr-master /sources/attr && cd /sources/attr
./configure --prefix=/usr \
	    --sysconfdir=/etc \
            --libdir=/usr/lib/x86_64-linux-gnu \
	    --silent
make --silent
make --silent install
# Compile acl
echo "Compiling acl..."
wget -qO- http://git.savannah.gnu.org/cgit/acl.git/snapshot/acl-master.tar.gz | tar -zxf- -C /sources/
mv /sources/acl-master /sources/acl && cd /sources/acl
./configure --prefix=/usr \
	    --libdir=/usr/lib/x86_64-linux-gnu \
	    --silent
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make --silent
make --silent install
# Compile xxhash
echo "Compiling xxhash..."
wget -qO- https://github.com/Cyan4973/xxHash/archive/refs/heads/dev.tar.gz | tar -zxf- -C /sources/
cd /sources/xxhash
wget -qO- https://github.com/archlinux/svntogit-community/raw/packages/xxhash/trunk/xxhash-man-symlinks.patch | patch -Np1 -i-
make --silent PREFIX=/usr
make --silent PREFIX=/usr install
install -Dm644 LICENSE -t /usr/share/licenses/xxhash
