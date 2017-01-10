##################
# Shell commands #
##################

function generate-makefile () {
touch Makefile
echo "
EXTRACFLAGS = -Wno-unknown-pragmas
EXTRA_LIBS =

MODULE = run
SRCS = \$(wildcard src/*.cpp)

include \$(FORSYDE_MAKEDEFS)

CFLAGS += -DFORSYDE_INTROSPECTION

" > Makefile
}

function init-sysc-project () {
    generate-makefile
    mkdir -p src
    mkdir -p files
    touch .project
    mkdir -p xml
}


function clean-project {
    if [ ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    rm xml/*
    find . -maxdepth 1 -mindepth 1 -not \( -name 'src' -or -name 'files' -or -name 'xml' -or -name 'Makefile' -or -name '.project' \)  -exec rm -rf "{}" \;
}


#################
# Help commands #
#################

function info-init-sysc-project () {
    echo "init-sysc-project : initializes current directory as a ForSyDe-SystemC project"
}

function info-clean-project () {
    echo "clean-project : cleans all generated files in a project"
}

function help-init-sysc-project () {
    info-init-sysc-project 
    echo "
Usage: init-sysc-project

The current folder will be a structured as a ForSyDe-Shell SystemC project."
}

function help-clean-project () {
    info-clean-project
    echo " 

Usage: clean-project

Needs to be called from a project root folder!
"   
}

function _print-general () {
    echo " * $(info-clean-project)"
    echo " * make clean : cleans the results of a compialtion (no help)"
    echo " * make : GNU make for compiling ForSyDe-SystemC projects (no help)"
    echo " * $(info-init-sysc-project)"    
}
