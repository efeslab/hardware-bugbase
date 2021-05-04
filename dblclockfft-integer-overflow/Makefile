include ../common/Makefile.env
RTL_SOURCES?=source.txt
TOP_MODULE?=fftmain
all: verilator sw

verilator:
	verilator -cc -F source.txt -top-module fftmain -Wno-TIMESCALEMOD --trace --assert -Wno-PINMISSING -Wno-VLTAG
	cd obj_dir; $(MAKE) -f Vfftmain.mk

sw: verilator
	cd test; $(MAKE)

clean:
	cd test; $(MAKE) clean
	rm -rf *.iq *.raw *.xml obj_dir

sim:
	cd test; $(MAKE) test

wave:
	gtkwave test/*.vcd >/dev/null 2>/dev/null &

# for resource-util synthesize
TOP_MODULE_SYNTH=fft_wrapper
TCLGEN_SRCS=vivado_synth/fft_wrapper.v
TCL_TEMPLATE=tcl.template
SV2V_OUT_FILES+=withtask
CODE_GEN+=withtask.v bug12.v

withtask.v: ${RTL_SOURCES} bug12.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config bug12.instrument.cfg --reset "i_reset"

DEPTH_SWEEP_PREFIX+=depth_sweep_bug12
depth_sweep_bug12_d%.v: ${RTL_SOURCES} bug12.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config bug12.instrument.cfg --reset "!i_reset" --config-override="{\"LOG2_SAMPLE_DEPTH\":$*, \"SV2V_OUTPUT\":\"$@\", \"ILA_OUTPUT\":\"$(basename $@).ila.tcl\"}"
include ../common/Makefile.ILA.rules
