#!/usr/bin/env python3
import argparse
import glob
import re
import sys
from utils import analyse_dir_summary
from utils import INTERESTING_HEADERS

SEP=","
WIDTH_RE = r'w([0-9]+)'
DEPTH_RE = r'd([0-9]+)'
"""
Return (width: int, depth: int) if the given name matches
else return None
"""
def getWidthDepth(name: str):
    width = re.findall(WIDTH_RE, name)
    depth = re.findall(DEPTH_RE, name)
    if len(width) == 1 and len(depth) == 1:
        return (int(width[0]), int(depth[0]))
    else:
        return None

parser = argparse.ArgumentParser(description="Print a grid of Resource Util from xilinx report in given synth directories")
parser.add_argument('prefix', type=str, help="the prefix of sweep build directories. The rest of the name should be ${prefix}_w{%%d}_d{%%d}")
parser.add_argument('--instance', type=str, default=None, help="Report the overhead of what instance in the circuit? (by default do not match")
parser.add_argument('--module', type=str, default=None, help="Report the overhead of what module in the circuit? (by default do not match")
args = parser.parse_args()

if not (args.instance or args.module):
    parser.error("Need to match at least one of instance name or module name")

all_dirs = glob.glob(args.prefix+'*w*d*')
all_width = set()
all_depth = set()
# {(width, depth) -> analyse_summary}
all_summaries = {}
all_keys = set()
for d in all_dirs:
    width, depth = getWidthDepth(d)
    all_width.add(width)
    all_depth.add(depth)
    res = analyse_dir_summary(d, args.instance, args.module)
    if res is None:
        print("Please check {}".format(d))
    else:
        all_keys |= res.keys()
        all_summaries[(width, depth)] = res
all_width_ordered = sorted(all_width)
all_depth_ordered = sorted(all_depth)
all_keys_ordered = [ kvpair[1] for kvpair in sorted(INTERESTING_HEADERS.items(), key=lambda p: p[0]) ]
assert(set(all_keys_ordered) == all_keys)
if len(all_summaries) != len(all_width) * len(all_depth):
    print("Not all (width, depth) pairs are available")
    for w in all_width_ordered:
        for d in all_depth_ordered:
            if (w, d) not in all_summaries:
                print("({:d},{:d}) is missing".format(w, d))
                all_summaries[(w, d)] = dict([(k, "N/A") for k in all_keys_ordered])
for k in all_keys_ordered:
    print("Key: {}".format(k))
    print("log2(Width)↓/log2(Depth)→" + SEP, end='')
    print(SEP.join([str(d) for d in all_depth_ordered]))
    for w in all_width_ordered:
        print(SEP.join([str(w)] + [str(all_summaries[(w,d)][k]) \
            for d in all_depth_ordered]))
