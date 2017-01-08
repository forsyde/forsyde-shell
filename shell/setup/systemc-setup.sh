#!/bin/bash

function search-systemc-path () {
    dialog --backtitle "ForSyDe-SystemC" \
	   --title "System Information",  \
	   --infobox 'Please wait while the setup gathers information about the system... \n\n (or press Ctrl+C to fill it in manually)' \
	   10 55
    trap ' ' INT
    local __syscpath=$(find /usr/local /opt ~ -type f -name "systemc.h"  2>/dev/null -print | head -n 1)
    if [ -n "$__syscpath" ]; then syscpath=$__syscpath; fi
    if [ -n "$syscpath" ];   then syscpath=$(dirname $(dirname $syscpath)) ; fi
    trap $(exit 0) INT
}

function install-systemc-locally () {
    local dir_systemc=$(basename $pkg_systemc .tar.gz)
    local dest_pkg=$libdir/$pkg_systemc

    if [ -d "$libdir/$dir_systemc" ]; then
	syscpath=$libdir/$dir_systemc
	local fail_msg="SystemC already installed at:\n$libdir/$dir_systemc"
	dialog --title "Skipping SystemC installation" --msgbox "$fail_msg" 13 70
	return 1
    fi
	
    if ! check_url "$url_systemc" "application/x-gzip"; then
	local fail_msg="The download link for SystemC is invalid:\n$url_systemc\n\nPlease install SystemC manually and retry running the setup.\n\nAborting installation!"
	dialog --title "Setup failure!" --msgbox "$fail_msg" 13 70
	clear
	exit 1
    fi

    if ! [ -f "$dest_pkg" ]; then
	if ! download_url "$dest_pkg" "$url_systemc"; then	
	    local fail_msg="Cannot download SystemC package from:\n$url_systemc\n\nPlease install SystemC manually and retry running the setup.\n\nAborting installation!"
	    dialog --title "Setup failure!" --msgbox "$fail_msg" 13 70
	    clear
	    exit 1
	fi
    fi

    mkdir -p $libdir
    mv $pkg_systemc $libdir
    cd $libdir
    tar -zxvf $pkg_systemc
    # rm $pkg_systemc
    cd $dir_systemc
    mkdir objdir
    cd objdir
    ../configure
    make
    make install
    cd ..
    rm objdir
    syscpath=$(pwd)
    cd $homedir
}

