#!/usr/bin/env python3
import argparse
from utils import report_dir_summary

parser = argparse.ArgumentParser(description="Print Resource Util of xilinx implementation results")
parser.add_argument('--instance', type=str, default=None, help="Report the overhead of what instance in the circuit? (by default do not match")
parser.add_argument('--module', type=str, default=None, help="Report the overhead of what module in the circuit? (by default do not match")
parser.add_argument('dirs', nargs='+', help="synthesis directories")
args = parser.parse_args()

if not (args.instance or args.module):
    parser.error("Need to match at least one of instance name or module name")

for d in args.dirs:
    report_dir_summary(d, args.instance, args.module)
