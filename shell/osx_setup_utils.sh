#!/bin/bash

arch_string='macosx'
if [[ $(uname -m) ==  *x86_64* ]]; then arch_string='macosx64'; fi

if [[ $(port installed dialog | grep "None" ) ]]; then sudo port install dialog; fi


################
# Dependencies #
################

dep_general='git'
dep_sysc='boost wget'
dep_f2dot='py-pygraphviz graphviz-gui'
dep_valgrind='valgrind graphviz gnuplot'
#dep_fm2m='saxon'

xcode-select --install

line_feed=$'\n';


###########
# Methods #
###########


function update_package_manager () {
    sudo port selfupdate
}

function create_runner () {
    touch forsyde-shell
    echo '#!/bin/bash
open -a Terminal.app shell/osx_runner' > forsyde-shell
    chmod +x forsyde-shell

    touch shell/osx_runner
    echo "#!/bin/bash
bash --rcfile ${homedir}/shell/forsyde-shell.sh" > shell/osx_runner
    chmod +x shell/osx_runner
}

function install-application () {
    if ! $(command -v $1 >/dev/null); then sudo port install $@; fi
}

function install-dependencies () {
    for dep in $@; do
	if  [[ $(port installed $dep | grep "None" ) ]]; then sudo port install $@; fi
    done
}

function clone-repo () {
    repo_string="${@:1:$#-1}"
    dest_dir="${!#}"
    if [ ! -d $dest_dir ]; then
	git clone $repo_string $dest_dir
    else
	cd $dest_dir
	git pull
	cd $homedir
    fi
}


# Force-adds a variable to $shconf.
# $1 : variable name as string (will be expanded)
# $2 : variable value as string
function force-add-var {
    source $shconf
    name=$1 
    value=(${!name})
    if [ -n "$value" ]; then	
	grep -v "$1=" $shconf > temp && mv temp $shconf
    fi
    echo "$1=$2" >> $shconf 
}

# Adds a variable to $shconf if it is not initialized and exports it.
# $1 : variable name as string (will be expanded)
# $2 : variable value as string
function add-export-var {
    source $shconf
    name=$1 
    value=(${!name})
    if [ -z "$value" ]; then
	echo "export $1=$2" >> $shconf 
    fi
}

# Force-adds a variable to $shconf and exports it.
# $1 : variable name as string (will be expanded)
# $2 : variable value as string
function force-export-var {
    source $shconf
    name=$1 
    value=(${!name})
    if [ -n "$1" ]; then	
	grep -v "$1=" $shconf > temp && mv temp $shconf
    fi
    echo "export $1=$2" >> $shconf 
}

# Checks if a provided url contains a file or not.
# $1 : ftp url
# $2 : validation string (usually type of file or size, etc...)
function check_url(){
    echo "    Sniffing url $1"
    if [[ ! `wget -S --spider $1 2>&1 | egrep "$2"` ]]; then 
	echo "    WARNING: Broken link '$1'"
	return 1
    fi
    return 0
}

# Downloads a file from a ftp url.
# $1 : output file
# $2 : ftp url
function download_url(){
    echo "    Downloading file '$1' from $2 "
    wget --progress=bar:force $2 -P . 2>&1 
    if [ ! -f $1 ]; then 
	echo "    WARNING: Failed to download file '$1' from $2"
    fi	
    return 0
}
