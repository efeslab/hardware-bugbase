#!/bin/sh
# Usage:
# 1. Generate sweep configurations
#    ./sweep.sh gen
# 2. Generate makefile targets
#    ./sweep.sh make > jobs.txt
#    parallel -j 10 < jobs.txt
# 3. Check missing resource util reports of sweep configurations
# NOTE: designed to sweep based on xilinx-axi-lite-incomplete-implementation
sweep() {
	func=$1
	for w in `seq 5 10`; do
		for d in `seq 10 13`; do
			$func $w $d
		done
	done
}
gen() {
	w=$1
	d=$2
	name=sweep_w${w}_d${d}
	${HOME}/FPGA/veripass/tools.py --top xlnxdemo -F sources.txt --reset "!S_AXI_ARESETN" -o ${name}.v sv2v --tasksupport --tasksupport-mode=SWEEPILA --tasksupport-log2width ${w} --tasksupport-log2depth ${d} --tasksupport-ila-tcl=${name}.ila.tcl
}
make() {
	w=$1
	d=$2
	name=sweep_w${w}_d${d}
	echo make build_${name}
}
check() {
	w=$1
	d=$2
	name=sweep_w${w}_d${d}
	build_dir=build_${name}
	rpt=build_${name}.util.rpt
	if [ ! -f $build_dir/${rpt} ]; then
		echo "${rpt} not found in" $build_dir
	fi
}

case $1 in
	gen)
		sweep gen ;;
	make)
		sweep make ;;
	check)
		sweep check ;;
	*) echo "${0} gen|check"
esac
