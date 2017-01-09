#!/bin/bash

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

# Returns the value of a variable in a configuration file 
# without sourcing it (thus overwriting the existing ones)
# $1 : config file
# $2 : variable (will be expanded)
function get-var () {
    . $1
    local name=$2
    local value=(${!name})
    echo "$value"
}

# Force-adds a variable to configuration file.
# $1 : config file
# $2 : variable name as string 
# $3 : variable value as string
function force-add-var {
    name=$2
    #value=(${!name})
    value=$(get-var $1 $2)
    if [ -n "$value" ]; then	
	grep -v "$name=" $1 > temp && mv temp $1
    fi
    echo "$name=$3" >> $1 
}

# Adds a variable to $1 if it is not initialized and exports it.
# $1 : config file
# $2 : variable name as string
# $3 : variable value as string
function add-export-var {
    #source $1
    # name=$2
    #value=(${!name})
    value=$(get-var $1 $2)
    if [ -z "$value" ]; then
	echo "export $2=$3" >> $1 
    fi
}

# Force-adds a variable to $1 and exports it.
# $1 : config file
# $2 : variable name as string
# $3 : variable value as string
function force-export-var {
    #source $1
    # name=$2
    #value=(${!name})
    value=$(get-var $1 $2)
    if [ -n "$2" ]; then	
	grep -v "$2=" $1 > temp && mv temp $1
    fi
    echo "export $2=$3" >> $1 
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


# both $1 and $2 are absolute paths
# returns $2 relative to $1
function relative-path () {
    local source=$1
    local target=$2

    local common_part=$source
    local back=
    while [ "${target#$common_part}" = "${target}" ]; do
	common_part=$(dirname $common_part)
	back="../${back}"
    done

    echo ${back}${target#$common_part/}
}
