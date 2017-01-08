##################
# Shell commands #
##################
function __pull {
    for repo in $(find $1 -type d -name ".git"); do
	cd $(dirname $repo)
	pwd
	git pull
    done
}

function pull  {
    workdir=$(pwd)
    case $1 in
	-w* ) __pull $SHELL_ROOT/$projdir ;;
	-l* ) __pull $SHELL_ROOT/$libdir ;;
	-t* ) __pull $SHELL_ROOT/$tooldir ;;
	* )   __pull $SHELL_ROOT ;;
    esac
    cd $workdir
}


#################
# Help commands #
#################

function info-pull () {
    echo "pull : pulls the latest versions of the included repositories"
}

function help-pull () {
    info-pull
    echo " 

Usage: pull [option]

option        what to update
  -a --all         everything (default)
  -w --workspace   only the projects in workspace
  -l --libraries   only libraries
  -t --tools       only tools
"   
}

function _print-general () {
    echo " * $(info-pull)"
}
