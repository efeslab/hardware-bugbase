Source: https://zipcpu.com/formal/2018/12/28/axilite.html

Vivado Synth report util (tcl):
`report_utilization -hierarchical -file util_1.rpt`

Vivado Synth instructions:
1. Use sv2v.py to create notask.v and withtask.v (special options are listed in
   the Makefile). Note that these are still systemverilog code (due to
   `always_comb`) so they need a verilog wrapper to be synthesizable.
2. Import the verilog wrapper file (`vivado_synth/xlnxdemo_wrapper.v`) as source
   code to an opened project in vivado.
3. Tweak the module and instance names so that there are two wrappers, each
   contains one buggy AXI-lite slave (with and without display instrumentation)
