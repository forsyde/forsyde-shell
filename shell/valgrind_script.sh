function _exec_to_csv () {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
	func_list=$(xml_grep "process_network/leaf_process/process_constructor/argument[@name='_func']" \
			     ir/*.xml | grep -o -P '(?<=value=").*(?=")' | sort -u)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
	func_list=$(python -c "import xml.etree.ElementTree as ET; import glob; print '\n'.join([node.get('value') for name in glob.glob('ir/*.xml') for node in ET.parse(name).findall(\"./leaf_process/process_constructor/argument[@name='_func']\")])")
    else
	echo "Unknown OS! Cannot extract runtime execution"
	exit 1
    fi
    echo "Harvesting info about the following functions:\n $func_list"
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
	mkdir -p ir

    if [[ "$@" == *"-p"* ]]; then
	mkdir -p exec_times
	valgrind --tool=callgrind -q --dump-after=sc_core::sc_start \
	    --callgrind-out-file=$callgrind_out ./run.x
	touch $annotated_cal
	callgrind_annotate $callgrind_out > $annotated_cal
	rm $callgrind_out
    else
	./run.x
    fi

    if [[ "$@" == *"-csv"* ]]; then
	if [[ ! -d ir ]] || [[ ! -f $annotated_cal ]]; then 
	    echo "Intermediate representation or extracted execution is missing. Will not write csv!"; 
	    return 0
	fi
	_exec_to_csv $annotated_cal $exec_csv
    fi

    if [[ "$@" == *"-pdf"* ]]; then
	if [[ ! -d ir ]] || [[ ! -f $annotated_cal ]]; then 
	    echo "Intermediate representation or extracted execution is missing. Will not plot pdf!"; 
	    return 0
	fi
	if [[ ! -f $exec_csv ]]; then   
	    _exec_to_csv $annotated_cal $exec_csv
        fi 
	_exec_to_pdf $exec_csv $exec_pdf
    fi
}


function info-execute-model () {
    echo "execute-model : runs a ForSyDe model and extracts and plot performance"
}

function help-execute-model () {
    info-execute-model
    echo "By default, this command just executes a compiled model. By invoking it 
with the appropriate flags it can extract run-time measurements.

Usage: execute-model [-p [-csv] [-pdf]]

-p            Runs model extracting performance metrics with 'callgrind'
-csv          Extracts execution times for process functions
-pdf          Plots execution times for process functions in PDF format

This command needs to be invoked in the root folder of a project!
"   
}

