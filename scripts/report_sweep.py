#!/usr/bin/env python3
import argparse
import glob
import re
import itertools
from functools import reduce, partial
from operator import mul
from signaltap_util.utils import analyse_dir_summary as analyse_STP_dir_summary
from signaltap_util.utils import get_sorted_keys as stp_get_keys
from xilinxila_util.utils import analyse_dir_summary as analyse_ILA_dir_summary
from xilinxila_util.utils import get_sorted_keys as ila_get_keys

SEP=','
WIDTH_RE = r'w([0-9]+)'
DEPTH_RE = r'd([0-9]+)'
PATTERN_CONFIG = {
    WIDTH_RE: {
        "name": "log2(Width)",
        "sortkey": lambda x: int(x)
    },
    DEPTH_RE: {
        "name": "log2(Depth)",
        "sortkey": lambda x: int(x)
    }
}

def report_sweep(args, analyse_dir_summary, sorted_keys):
    # all_patterns should be a list of regex rules, each regex rule:
    # 1. matches exact one sweep variable
    # 2. contains exact one regex group representing the value of that sweep variable
    all_patterns = []
    all_dirs = glob.glob(args.prefix+'*')
    if args.pattern_width:
        all_patterns.append(WIDTH_RE)
    if args.pattern_depth:
        all_patterns.append(DEPTH_RE)
    if len(all_patterns) == 0:
        parser.error("No pattern specifcied")
    # { (sweep_var1, sweep_var2, ...) -> analyse_summary }
    all_summaries = {}
    # { sweep_var_rule -> set of values }
    sweep_vars_valset = dict([(p, set()) for p in all_patterns])
    for d in all_dirs:
        sweep_vars = []
        for p in all_patterns:
            match = re.findall(p, d)
            assert(len(match) == 1)
            val = match[0]
            sweep_vars.append(val)
            sweep_vars_valset[p].add(val)
        sweep_vars_tuple = tuple(sweep_vars)
        res = analyse_dir_summary(d)
        all_summaries[sweep_vars_tuple] = res
    expected_N_summaries = reduce(mul, [len(valset) for valset in sweep_vars_valset.values()])
    if len(all_summaries) != expected_N_summaries:
        print("Not all sweep var pairs are available")
        for sweep_vals in itertools.product(*sweep_vars_valset.values()):
            if sweep_vals not in all_summaries:
                vars_vals_str = ["\"{}\"={}".format(var, val) for var, val in zip(sweep_vars_valset.keys(), sweep_vals)]
                print("{} is missing".format(', '.join(vars_vals_str)))
    else:
        all_vars = list(sweep_vars_valset.keys())
        if len(all_vars) == 1:
            single_var = all_vars[0]
            var_config = PATTERN_CONFIG[single_var]
            var_vals = sorted(list(sweep_vars_valset[single_var]), key=var_config["sortkey"])
            print(SEP.join(
                [var_config["name"]] + var_vals
                ))
            for k in sorted_keys:
                print(SEP.join([k] + [str(all_summaries[(val,)][k]) for val in var_vals]))
        elif len(all_vars) == 2:
            var1 = all_vars[0]
            var1_cfg = PATTERN_CONFIG[var1]
            vals1 = sorted(list(sweep_vars_valset[var1]), key=var1_cfg["sortkey"])
            var2 = all_vars[1]
            var2_cfg = PATTERN_CONFIG[var2]
            vals2 = sorted(list(sweep_vars_valset[var2]), key=var2_cfg["sortkey"])
            for k in sorted_keys:
                print("Key: {}".format(k))
                print("\"{}\"↓/\"{}\"→".format(var1_cfg["name"], var2_cfg["name"]) + SEP, end='')
                print(SEP.join(vals2))
                for val1 in vals1:
                        print(SEP.join(
                            [val1] +
                            [str(all_summaries[(val1, val2)][k]) \
                                for val2 in vals2]))
        else:
            raise NotImplementedError("Cannot print >= 3D data")

parser = argparse.ArgumentParser(description="Print a grid of Resource Util.")
parser.add_argument("--mode", type=str, choices=["ILA", "STP"], help="ILA: find xilinx .util.rpt; STP: find skx_pr_afu.fit.summary")
parser.add_argument('--pattern-width', action="store_true", help="Customized regex-based sweep variable matching rule. \"w([0-9]+)\"")
parser.add_argument('--pattern-depth', action="store_true", help="Customized regex-based sweep variable matching rule. \"d([0-9]+)\"")
parser.add_argument('--instance', type=str, default=None, help="Report the overhead of what instance in the circuit? (by default do not match) (ILA only)")
parser.add_argument('--module', type=str, default=None, help="Report the overhead of what module in the circuit? (by default do not match) (ILA only)")
parser.add_argument('--prefix', type=str, help="The prefix of sweep build directories. The sweep variables should be defined via \"--pattern-*\"")
args = parser.parse_args()

if args.mode == "ILA":
    if not (args.instance or args.module):
        parser.error("Need to match at least one of instance name or module name")
    analyse_dir_summary = partial(analyse_ILA_dir_summary, instance_name=args.instance, module_name=args.module)
    sorted_keys = ila_get_keys()
elif args.mode == "STP":
    analyse_dir_summary = analyse_STP_dir_summary
    sorted_keys = stp_get_keys()
report_sweep(args, analyse_dir_summary, sorted_keys)
