function f2sdf3 () {
    if [  ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd) | sed 's|-|_|g')
    if [[ "${@:2}" == *"-d"* ]]; then
	debug_str="debug=yes"
    fi
    if [[ "${@:2}" == *"-p"* ]]; then
	permissive_str="permissive=yes"
    fi
    mkdir -p sdf3
    cp $FM2M_HOME/DTD/forsyde.dtd ir
    cp $FM2M_HOME/DTD/forsyde_types.dtd ir
    saxonb-xslt -s:$1 -xsl:$F2SDF3 -o:sdf3/log -dtd:off -ext:on $debug_str $permissive_str application-name=$projname types=$(cd ir; pwd)/types.xml inputFolder=$(cd ir; pwd)/ outputFolder=sdf3 2>&1 | tee sdf3/log | grep 'ERROR\|WARNING'
}

function info-f2sdf3 () {
    echo "f2sdf3 : converts generated ForSyDe-XML IR into SDF3 format"
}

function help-f2sdf3 () {
    info-f2sdf3
    echo "

Usage: f2sdf3 <in_xml> [-debug] [-permissive]

in_xml        Top level input file
-debug        Debug mode. Will output log file and intermetiate models
              in the default output folder.
-permissive   Permissive mode. Don't mind if non-critical information
              (like channel sizes) is not found.

This command needs to be invoked in the root folder of a project!
"   
}
