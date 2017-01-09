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

#xcode-select --install

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
