#!/bin/sh
# Usage:
# 1. Generate sweep configurations
#    ./sweep.sh gen > jobs.txt
#    parallel -j 10 < jobs.txt
# 2. Check missing resource util reports of sweep configurations
sweep() {
	func=$1
	for w in `seq 1 12`; do
		for d in `seq 1 17`; do
			$func $w $d
		done
	done
}
gen() {
	w=$1
	d=$2
	${HOME}/FPGA/veripass/sv2v.py --top ccip_std_afu_wrapper -F sources.txt --tasksupport --tasksupport-mode=SWEEP --tasksupport-log2width ${w} --tasksupport-log2depth ${d} -o sweep_w${w}_d${d}.v
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
	check)
		sweep check ;;
	*) echo "${0} gen|check"
esac
