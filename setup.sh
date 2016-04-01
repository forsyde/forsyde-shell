#!/bin/bash

homedir=$(pwd)
scriptpath=$(cd shell; pwd)
shfile=$scriptpath/forsyde-shell.sh
libdir=$homedir/libs
tooldir=$homedir/tools
projdir=$homedir/workspace
cmdstring=" Commands provided by this shell (type help-<command> for manual):"

repo_fsysc='https://github.com/ugeorge/ForSyDe-SystemC.git -b type-introspecion --single-branch'
repo_f2dot='https://github.com/forsyde/f2dot.git'
repo_fm2m='https://github.com/ugeorge/forsyde-m2m.git'
repo_fsysc_apps='https://github.com/forsyde/forsyde-systemc-demonstrators.git'

source shell/default.conf
source shell/debian_setup_utils.sh

function reset-shell () {
    rm $shfile
    rm forsyde-shell
}

function uninstall-shell () {
    read -p "Are you sure you want to completely remove the shell along with the install tools and libraries? [N]" yn
    case $yn in
	[Yy]* ) rm -rf $shfile $libdir $tooldir $projdir forsyde-shell ;;
	* ) ;;
    esac
    exit 0
}

function install-dialog () {
  
    cmd=(dialog --keep-tite --menu "Welcome to ForSyDe-Shell installer. What would you like to do?" 22 76 16)
    options=( 1 "Install/Update : installs libs & tools. Updates existing shell."
	      2 "Reset shell    : installs libs & tools. Resets existing shell" 
	      3 "Uninstall      : uninstalls libs, tools & the current shell.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    for choice in $choices; do
	case $choice in
            1) install_general=on ;;
            2) install_general=on; reset-shell ;;
	    3) uninstall-shell ;;
	esac
    done

    cmd=(dialog --separate-output --checklist 	"Which ForSyDe library would you like to install?" 22 76 16)
    options=(1 "ForSyDe-Haskell (not available yet)" $install_fhask  
             2 "ForSyDe-SystemC (prerquisite: SystemC)" $install_fsysc)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
    	case $choice in
            1) install_fhask=on ;;
            2) install_fsysc=on ;;
    	esac
    done

    if [ "$install_fsysc" = on ]; then
        dialog --backtitle "ForSyDe-SystemC" --title "System Information",  \
	    --infobox 'Please wait while the setup gathers information about the system... \n\n (or press Ctrl+C to fill it in manually)' \
	    10 55
	trap ' ' INT
	syscpath=$(find /usr/local /opt ~ -type f -name "systemc.h"  2>/dev/null -print | head -n 1)
	syscpath=$(dirname $(dirname $syscpath)) 
	trap $(exit 0) INT

	exec 3>&1
	VALUES=$(dialog --backtitle "ForSyDe-SystemC"  --title "System Information" --form "Fill in the information if not correct:"  \
	    15 86 0 \
	    "SystemC path: "                 1 1 "$syscpath"    1 15 70 0 \
	    "SystemC libs (name): lib-"      2 1 "$arch_string" 2 26 60 0 \
	    2>&1 1>&3)
	exec 3>&-
	syscpath=$(echo "$VALUES" |sed -n -e '1{p;q}')
	arch_string=$(echo "$VALUES" |sed -n -e '2{p;q}')

	cmd=(dialog --separate-output --checklist "What other features would you like to install?" 22 76 16)
	options=(1 "demo        : a collection of ForSyDe-SystemC demonstrators"  $install_fsysc_demo  
	         2 "f2dot       : plotting XML-based IR"                          $install_f2dot  
                 3 "forsyde-m2m : convert between ForSyDe and oher IRs"           $install_fm2m
                 4 "valgrind    : extract run-time executions of SystemC models." $install_valgrind)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $choices
	do
    	    case $choice in
		1) install_fsysc_demo=on ;;
		2) install_f2dot=on ;;
		3) install_fm2m=on ;;
		4) install_valgrind=on ;;
    	    esac
	done
    fi
}

function init-shell () {
    echo "[SETUP] : Setting up the shell environment"
    cp -n shell/forsyde-shell.template $shfile
    add-var "DEMO_HOME" "$(pwd)"

    echo "[SETUP] : Installing shell dependencies"
    install_dependencies $dep_general

    touch forsyde-shell
    echo '#!/bin/bash
gnome-terminal -e "bash --rcfile shell/forsyde-shell.sh"' > forsyde-shell
    chmod +x forsyde-shell
}

function install-forsyde-systemc {
    # syscpath=$(bash $scriptpath/setup-forsyde-systemc.sh $shfile | tail -n 1)
    # echo "$syscpath"
    # read -p "What is your machine architecture [linux64]" arch
    # if [ $arch ]; then arch_string=$arch; fi

    echo "[SETUP] : Installing ForSyDe-SystemC dependencies"
    echo "[SETUP] : SystemC path '$syscpath'"
    install_dependencies $dep_sysc

    echo "[SETUP] : Acquiring ForSyDe-SystemC libraries"
    clone_repo $repo_fsysc $libdir/ForSyDe-SystemC
    fsspath=$(cd $libdir/ForSyDe-SystemC; pwd)

    echo "[SETUP] : Creating  shell environment variables for SystemC-ForSyDe"
    add-var "SYSC_ARCH" $arch_string
    add-var "SYSTEMC_HOME" "$syscpath"
    add-var "LD_LIBRARY_PATH" "$syscpath/lib-$arch_string"
    add-var "SC_FORSYDE" "$fsspath/src"
    add-var "FORSYDE_MAKEDEFS" "$scriptpath/Makefile.defs"
    add-intro " * ForSyDe-SystemC" " Libraries included:"
}

function install-apps () {
    echo "[SETUP] : Installing applications from $1 "
    mkdir -p $projdir
    appdir=$projdir/$2
    clone_repo $1 $appdir

    for app in $(find $projdir -type f -name '.project' -printf '%P\n'); do
	appname=$(dirname $app)
	add-intro " * $appname" " Applications:"
    done
    add-intro "export WORKSPACE=${projdir}" "#vars begin";
}

function install-f2dot {
    echo "[SETUP] : Installing f2dot dependencies"
    install_dependencies $dep_f2dot
    f2dotpath=$tooldir/f2dot
    clone_repo $repo_f2dot $f2dotpath

    echo "[SETUP] : Creating  shell environment variables for f2dot"
    add-var "F2DOT" "$(cd $f2dotpath; pwd)/f2dot"
    add-intro ' * f2dot           script : \\\\$F2DOT' " Tools included:"
}

function install-forsyde-m2m {
    echo "[SETUP] : Installing dependencies for forsyde-m2m"
    install_dependencies $dep_fm2m
    fm2mpath=$tooldir/forsyde-m2m
    clone_repo $repo_fm2m $fm2mpath


    echo "[SETUP] : Creating  shell environment variables for forsyde-m2m "
    add-var "FM2M_HOME" "$(cd $fm2mpath; pwd)"
    add-var "F2SDF3" "$(cd $fm2mpath; pwd)/f2sdf3.xsl"
    add-intro ' * f2sdf3          script : \\\\$F2SDF3' " Tools included:"
}

function install-f2et {
    echo "[SETUP] : Installing valgrind"
    install_dependencies $dep_valgrind
}

function wrap-up () {
    echo "[SETUP] : Wrapping it all up..."

    if [ "$install_fm2m" = on ]; then
	add-script "$scriptpath/fm2m_script.sh"
	add-intro " * $(source $scriptpath/fm2m_script.sh; info-f2sdf3)" "$cmdstring"
    fi

    if [ "$install_f2dot" = on ]; then
	add-script "$scriptpath/f2dot_script.sh"
	add-intro " * $(source $scriptpath/f2dot_script.sh; info-plot)" "$cmdstring"
    fi

    if [ "$install_valgrind" = on ]; then    
	add-script "$scriptpath/valgrind_script.sh"
	add-intro " * $(source $scriptpath/valgrind_script.sh; info-execute-model)" "$cmdstring"
    fi

    if [ "$install_fsysc" = on ]; then
	add-script "$scriptpath/sysc_script.sh"
	add-intro "$(source $scriptpath/sysc_script.sh; _print-general);" "$cmdstring";
    fi

    if [ "$install_general" = on ]; then
	add-script "$scriptpath/general.sh"
	add-intro "$(source $scriptpath/general.sh; _print-general);" "$cmdstring";
    fi

    #sed -i 's/: \$/: \\\$/g' $shfile
}

####### MAIN ##########


if [[ $@ == *"-no-dialog"* ]]; then
    if [[ $@ == *"-reset"* ]]; then reset-shell; fi
    if [[ $@ == *"-uninstall"* ]]; then uninstall-shell; fi
    install_general=on
else
    install-dialog;
fi

if [ "$install_general" = on ];    then init-shell; fi
if [ "$install_fsysc" = on ];      then install-forsyde-systemc; fi
if [ "$install_fsysc_demo" = on ]; then install-apps $repo_fsysc_apps demo; fi
if [ "$install_f2dot" = on ];      then install-f2dot; fi
if [ "$install_fm2m" = on ];       then install-forsyde-m2m; fi
if [ "$install_valgrind" = on ];   then install-f2et; fi

wrap-up

#read -p "Would you like to install the SDF3 tool chain? [y]" yn
#case $yn in
#    [Nn]* ) ;;
#    * ) source shell/__obsolete.sh; install-sdf3;;
#esac
