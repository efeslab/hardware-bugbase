#!/bin/sh
# Usage:
# 1. Generate sweep configurations
#    ./sweep.sh gen
# 2. Generate makefile targets
#    ./sweep.sh make > jobs.txt
#    parallel -j 10 < jobs.txt
# 3. Check missing resource util reports of sweep configurations
# NOTE: designed to sweep based on sha512
sweep() {
	func=$1
	for w in `seq 5 11`; do
		for d in `seq 10 13`; do
			$func $w $d
		done
	done
}
gen() {
	${HOME}/FPGA/veripass/tools.py --top ccip_std_afu_wrapper -F sources.txt -o sweep_w${w}_d${d}.v sv2v --tasksupport --tasksupport-mode=SWEEPSTP --tasksupport-log2width ${w} --tasksupport-log2depth ${d}
}
make() {
	w=$1
	d=$2
	echo make build_sweep_w${w}_d${d}
}
check() {
	w=$1
	d=$2
	build_dir=build_sweep_w${w}_d${d}
	if [ ! -f $build_dir/build/output_files/skx_pr_afu.fit.summary ]; then
		echo "skx_pr_afu.fit.summary not found in" $build_dir
	fi
}

case $1 in
	gen)
		sweep gen ;;
	make)
		sweep make;;
	check)
		sweep check ;;
	*) echo "${0} gen|check"
esac
