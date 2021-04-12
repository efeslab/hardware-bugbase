import re
import os
MATCH_RULES = {
        'ALM': r'Logic utilization \(in ALMs\) : ([0-9,]+)',
        'BRAMbit' : r'Total block memory bits : ([0-9,]+)',
        'BRAM#B' : r'Total RAM Blocks : ([0-9,]+)',
        }
"""
Return : {str -> int}
Dict keys are the same as the above MATCH_RULES
"""
def analyse_summary(summary: str):
    result = {}
    for key, rule in MATCH_RULES.items():
        m = re.findall(rule, summary)
        assert(len(m) == 1)
        result[key] = int(m[0].replace(',', ''))
    return result

def analyse_dir_summary(dirname: str):
    fit_summary = os.path.join(dirname, 'build', 'output_files', 'skx_pr_afu.fit.summary')
    if not os.path.exists(fit_summary):
        return None
    with open(fit_summary, 'r') as f:
        summary = f.read()
        return analyse_summary(summary)

def report_dir_summary(dirname: str):
    res = analyse_dir_summary(dirname)
    if res:
        print("{}: {}".format(dirname, str(res)))
    else:
        print("Cannot find skx_pr_afu.fit.summary in {}".format(dirname))
