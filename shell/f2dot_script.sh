function plot () {
    if [  ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd))
    mkdir -p plots
 
    mode=''
    case  $(dirname ${@: -1}) in
        sdf3 )  mode="sdf3" ;;
	*    )  mode="forsyde";;

    esac

	conf_file=$mode.conf
    echo "$conf_file"
    if [ ! -f files/$conf_file ]; then 	
	mkdir -p files 
	python $F2DOT -g -m $mode -o files > /dev/null
    fi 
    python $F2DOT -c files/$conf_file -m $mode -o plots "$@"
}


function info-plot () {
    echo "plot : plots generated ForSyDe-XML intermediate representation"
}

function help-plot () {
    python $F2DOT -h
    info-f2dot
    echo "

Usage: plot [f2dot_args] <in_xml>

in_xml        Top level input file
f2dot_args    Arguments to f2dot, as printed above. Overrides the 
              output to 'plots'

This command needs to be invoked in the root folder of a project!
"   
}

function _print-f2dot () {
    echo " * $(info-plot)"
}
