#!/usr/bin/env python3
import argparse
from utils import report_dir_summary

parser = argparse.ArgumentParser(description="Print Resource Util of skx_pr_afu.fit.summary in given synth directories")
parser.add_argument('dirs', nargs='+', help="synth directories")
args = parser.parse_args()

for d in args.dirs:
    report_dir_summary(d)
