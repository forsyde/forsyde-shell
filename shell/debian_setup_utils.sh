#!/bin/bash

arch_string='linux'
if [[ $(uname -m) ==  *x86_64* ]]; then arch_string='linux64'; fi

################
# Dependencies #
################

dep_dialog='dialog'
dep_general='build-essential git'
dep_sysc='libboost-dev'
dep_f2dot='python python-pygraphviz xdot'
dep_valgrind='valgrind kcachegrind graphviz xml-twig-tools gnuplot'
dep_fm2m='default-jre libsaxonb-java'

###########
# Methods #
###########

function install_dependencies () {
    if ! $(dpkg -l $@ &> /dev/null); then sudo apt-get install -y $@; fi
}

function clone_repo () {
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

function add-var {
    if ! grep -q "$1" $shfile ; then
	sed -i "s|#vars end|export $1=$2\n#vars end|g" $shfile
    fi
}

function add-script {
    if ! grep -q "$1" $shfile ; then
	sed -i "s|#scripts end|source $1\n#scripts end|g" $shfile
    fi
}

function add-intro {
    echo "$1" | while read line; do
	if ! grep -q "$line" $shfile ; then
	    sed -i "s|$2|$2\n$line|g" $shfile
	fi
    done 
}

function check_url(){
    echo "    Sniffing url $1"
    if [[ ! `wget -S --spider $1 2>&1 | egrep 'HTTP.* 200 OK|File .* exists'` ]]; then 
	echo "    WARNING: Broken link '$1'"
	return 1
    fi
    return 0
}

function download_url(){
    echo "    Downloading file '$1' from $2 "
    wget --progress=bar:force $2 -P . 2>&1 
    if [ ! -f $1 ]; then 
	echo "    WARNING: Failed to download file '$1' from $2"
    fi	
    return 0
}
