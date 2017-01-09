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

function create_runner () {
    touch forsyde-shell
    echo '#!/bin/bash
gnome-terminal -e "bash --rcfile shell/forsyde-shell.sh"' > forsyde-shell
    chmod +x forsyde-shell
}

function install-application () {
    if ! $(command -v $1 >/dev/null); then sudo apt-get install -y $@; fi
}

function install-dependencies () {
    if ! $(dpkg -l $@ &> /dev/null); then sudo apt-get install -y $@; fi
}
