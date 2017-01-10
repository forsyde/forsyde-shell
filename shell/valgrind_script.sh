# Runs callgrind and annotates output with function names.
# $1 : intermediate un-anotated file path
# $2 : annotated output
function _exec_to_callgrind () {
    mkdir -p xml
    mkdir -p exec_times
    valgrind --tool=callgrind -q --dump-after=sc_core::sc_start \
	--callgrind-out-file=$1 ./run.x
    touch $2
    callgrind_annotate $1 > $2
    rm $1
}

function _exec_to_csv () {
    ls xml/*.xml  >/dev/null || (echo "ERROR: Intermediate representation is missing. Aborting!"; return 0)
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
	func_list=$(xml_grep "process_network/leaf_process/process_constructor/argument[@name='_func']" \
			     xml/*.xml | grep -o -P '(?<=value=").*(?=")' | sort -u)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
	func_list=$(python -c "import xml.etree.ElementTree as ET; import glob; print '\n'.join([node.get('value') for name in glob.glob('xml/*.xml') for node in ET.parse(name).findall(\"./leaf_process/process_constructor/argument[@name='_func']\")])")
    else
	echo "Unknown OS! Cannot extract runtime execution"
	exit 1
    fi
    echo "Harvesting info about the following functions:"
    echo "$func_list"
    echo "" > $2
    for func in $func_list; do
        echo "$func $(less $1 | grep -e $func | awk '{print $1}' | tr -d ,)" >> $2
    done
}

function _exec_to_pdf () {
    gnuplot <<EOF
set term pdf
set output "$2"
set boxwidth 0.5
set style fill solid
set xtics rotate by -30
plot '$1' using 0:2 title '', '' using 0:2:xtic(1) title 'exec_times' with boxes
EOF
    
}

function execute-model () {
    if [ ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd))
    timestamp=$(date +"_%y%m%d_%H%M%S")
    callgrind_out=exec_times/callgrind$timestamp.out
    annotated_cal=exec_times/annotated$timestamp.out
    exec_csv=exec_times/exec_$projname$timestamp.csv
    exec_pdf=exec_times/exec_$projname$timestamp.pdf

    case $@ in
	-p )   _exec_to_callgrind $callgrind_out $annotated_cal ;;
	-csv ) _exec_to_callgrind $callgrind_out $annotated_cal;
	       _exec_to_csv $annotated_cal $exec_csv ;;
	-pdf ) _exec_to_callgrind $callgrind_out $annotated_cal; 
	       _exec_to_csv $annotated_cal $exec_csv;
	       _exec_to_pdf $exec_csv $exec_pdf;;
	'' )   ./run.x ;;
	* )    echo 'ERROR: cannot recognize parameter!'; help-execute-model;;
    esac

}


function info-execute-model () {
    echo "execute-model : runs a ForSyDe model and extracts and plot performance"
}

function help-execute-model () {
    info-execute-model
    echo "By default, this command just executes a compiled model. By invoking it 
with the appropriate flags it can extract run-time measurements.

Usage: execute-model [-p|-csv|-pdf]

-p            Runs model extracting performance metrics with 'callgrind'
-csv          Extracts execution times for process functions
-pdf          Plots execution times for process functions in PDF format

This command needs to be invoked in the root folder of a project!
"   
}

