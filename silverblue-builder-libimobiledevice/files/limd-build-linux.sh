#!/bin/bash

# If you like this script and my work on libimobiledevice, please
# consider becoming a patron at https://patreon.com/nikias - Thanks <3

REV=1.0.2

if test -x "`which tput`"; then
  ncolors=`tput colors`
  if test -n "$ncolors" && test $ncolors -ge 8; then
    BOLD="$(tput bold)"
    UNDERLINE="$(tput smul)"
    STANDOUT="$(tput smso)"
    NORMAL="$(tput sgr0)"
    BLACK="$(tput setaf 0)"
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    MAGENTA="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
    WHITE="$(tput setaf 7)"
  fi
fi

 echo -e "${BOLD}**** libimobiledevice stack build script for Linux, revision $REV ****${NORMAL}"

#if test -x `which dnf`; then
#  # debian based distro
#  echo -e "${WHITE}Checking dependencies...${NORMAL}"
#  #PKGS="build-essential checkinstall git autoconf automake libtool-bin libssl-dev libusb-1.0-0-dev pkg-config cython3 libzip-dev libcurl4-openssl-dev libfuse-dev"
#  PKGS="git autoconf automake libtool-bin libssl-dev libusb-1.0-0-dev pkg-config cython3 libzip-dev libcurl4-openssl-dev libfuse-dev"
#  for P in $PKGS; do
#    CHECK=`rpm -q $P 2>/dev/null |grep $P`
#    if test -z "$CHECK"; then
#      TO_BE_INSTALLED="$TO_BE_INSTALLED $P"
#    fi
#  done
#  if test -z "$TO_BE_INSTALLED"; then
#    echo -e "${WHITE}All dependencies installed${NORMAL}"
#  else
#    echo -e "${WHITE}Installing missing dependencies${NORMAL}"
#    sudo dnf install -y $TO_BE_INSTALLED || exit 1
#  fi
#else
#  echo -e "${RED}WARNING: Unknown package mananger, make sure to manually install the required build dependencies.${NORMAL}"
#fi

if test $UID -eq 0; then
  if test -z $RUN_AS_ROOT; then
    echo -e "${RED}WARNING: It is *NOT* recommended to run this script as root. See -h for help.${NORMAL}"
    echo -e "If you still want to run it as root, set environment variable RUN_AS_ROOT=1"
    exit 1
  else
    echo -e "${RED}WARNING: Running as root (enforced via env RUN_AS_ROOT)${NORMAL}"
  fi
fi

if test -n "$CFLAGS"; then
  echo -e "${YELLOW}NOTE: Using externally defined CFLAGS. If that's not what you want, run: unset CFLAGS${NORMAL}"
fi

if test -z "$PREFIX"; then
  PREFIX="/usr/local"
else
  echo -e "${YELLOW}NOTE: Using externally defined PREFIX. If that's not what you want, run: unset PREFIX${NORMAL}"
fi
echo -e "${BOLD}PREFIX:${NORMAL} ${GREEN}$PREFIX${NORMAL}"
INSTALL_DIR=$PREFIX
if test -n "$DESTDIR"; then
  case "$DESTDIR" in
    /*) export DESTDIR="$DESTDIR" ;;
    *)  export DESTDIR="`pwd`/$DESTDIR" ;;
  esac
  mkdir -p "$DESTDIR"
  echo -e "${BOLD}DESTDIR:${NORMAL} ${GREEN}$DESTDIR${NORMAL}"
  INSTALL_DIR=$DESTDIR
fi

if ! test -w "$INSTALL_DIR"; then
  echo -e "${YELLOW}NOTE: During the process you will be asked for your password, this is to allow installation of the built libraries and tools via ${MAGENTA}sudo${YELLOW}.${NORMAL}"
fi

INSTALL_SUDO=
POSTINSTALL=
if test -z $DESTDIR; then
  if ! test -w $PREFIX; then
    INSTALL_SUDO="sudo"
  fi
fi

CURDIR=`pwd`

#############################################################################
COMPONENTS="
  libplist:master \
  libimobiledevice-glue:master \
  libusbmuxd:master \
  libimobiledevice:master  \
  usbmuxd:master \
  libirecovery:master \
  idevicerestore:master \
  libideviceactivation:master \
  ideviceinstaller:master \
  ifuse:master \
"
# error helper function
function error_exit {
  echo "$1"
  exit 1
}

if test -z "$NO_CLONE"; then
echo
echo -e "${CYAN}######## UPDATING SOURCES ########${NORMAL}"
echo
for I in $COMPONENTS; do
  COMP=`echo $I |cut -d ":" -f 1`;
  CVER=`echo $I |cut -d ":" -f 2`;
  if test -d "$COMP/.git" && ! test -f "$COMP/.git/shallow"; then
    cd $COMP
    if test -z "`git branch |grep '$CVER'`"; then
      git checkout $CVER --quiet || error_exit "Failed to check out $CVER"
    fi
    if test "$CVER" != "master"; then
      echo "Updating $COMP (release $CVER)";
    else
      echo "Updating $COMP";
    fi
    git reset --hard --quiet
    git pull --quiet || error_exit "Failed to pull from git $COMP"
    cd "$CURDIR"
  else
    rm -rf $COMP
    if test "$CVER" != "master"; then
      echo "Cloning $COMP (release $CVER)";
      git clone -b $CVER https://github.com/libimobiledevice/$COMP 2>/dev/null || error_exit "Failed to clone $COMP"
    else
      echo "Cloning $COMP (master)";
      git clone https://github.com/libimobiledevice/$COMP 2>/dev/null || error_exit "Failed to clone $COMP"
    fi
  fi
done
fi

#############################################################################
echo
echo -e "${CYAN}######## STARTING BUILD ########${NORMAL}"
echo
#############################################################################

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

function error_out {
  echo -e "${RED}ERROR: ${STEP} failed for ${COMP}, check ${YELLOW}${LOGF}${RED} for details.${NORMAL}"
  exit 1
}

#############################################################################
COMP=libplist
echo -e "${BOLD}#### Building libplist ####${NORMAL}"
cd libplist
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" --without-cython > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo ldconfig
cd "$CURDIR"

#############################################################################
COMP=libimobiledevice-glue
echo -e "${BOLD}#### Building libimobiledevice-glue ####${NORMAL}"
cd libimobiledevice-glue
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo ldconfig
cd "$CURDIR"

#############################################################################
COMP=libusbmuxd
echo -e "${BOLD}#### Building libusbmuxd ####${NORMAL}"
cd libusbmuxd
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo ldconfig
cd "$CURDIR"

#############################################################################
COMP=libimobiledevice
echo -e "${BOLD}#### Building libimobiledevice ####${NORMAL}"
cd libimobiledevice
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" --enable-debug --without-cython > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo ldconfig
cd "$CURDIR"

#############################################################################
COMP=usbmuxd
echo -e "${BOLD}#### Building usbmuxd ####${NORMAL}"
cd usbmuxd
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix=/usr --sysconfdir=/etc --localstatedir=/var --runstatedir=/run > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo killall usbmuxd
cd "${CURDIR}"

#############################################################################
COMP=libirecovery
echo -e "${BOLD}#### Building libirecovery ####${NORMAL}"
cd libirecovery
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo ldconfig
cd "$CURDIR"

#############################################################################
COMP=idevicerestore
echo -e "${BOLD}#### Building idevicerestore ####${NORMAL}"
cd idevicerestore
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
cd "$CURDIR"

#############################################################################
COMP=libideviceactivation
echo -e "${BOLD}#### Building libideviceactivation ####${NORMAL}"
cd libideviceactivation
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
sudo ldconfig
cd "$CURDIR"

#############################################################################
COMP=ideviceinstaller
echo -e "${BOLD}#### Building ideviceinstaller ####${NORMAL}"
cd ideviceinstaller
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
cd "$CURDIR"

#############################################################################
COMP=ifuse
echo -e "${BOLD}#### Building ifuse ####${NORMAL}"
cd ifuse
echo -e "[*] Configuring..."
STEP=configure
LOGF=$CURDIR/${COMP}_${STEP}.log
./autogen.sh --prefix="$PREFIX" > "$LOGF" 2>&1 || error_out
echo -e "[*] Building..."
STEP=build
LOGF=$CURDIR/${COMP}_${STEP}.log
make > "$LOGF" 2>&1 || error_out
echo -e "[*] Installing..."
STEP=install
LOGF=$CURDIR/${COMP}_${STEP}.log
$INSTALL_SUDO make install > "$LOGF" 2>&1 || error_out
cd "$CURDIR"

#############################################################################
echo
echo -e "${CYAN}######## BUILD COMPLETE ########${NORMAL}"
echo
echo -e "${BOLD}If you like this script and my work on libimobiledevice, please
consider becoming a patron at ${YELLOW}https://patreon.com/nikias${NORMAL}${BOLD} - Thanks ${RED}<3${NORMAL}"
echo
#############################################################################
