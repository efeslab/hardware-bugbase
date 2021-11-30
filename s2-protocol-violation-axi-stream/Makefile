include ../common/Makefile.env
RTL_SOURCES?=sources0
TOP_MODULE?=testbench
TEST_DIR?=test

VERILATOR=../../veripass/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc -timescale-override 10ps/10ps
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-PINMISSING
VERILATOR_OPT+= -trace-fst -trace-structs
VERILATOR_OPT+= -assert -trace-max-array 65536 -trace-max-width 65536
VERILATOR_ROOT=$(CURDIR)/../../veripass/verilator

CXX?= g++
CXX_OPT?=
CXX_OPT+= -g
CXX_OPT+= -I$(VERILATOR_ROOT)/include
CXX_OPT+= -lz
VERILATOR_CXX_FILES?= $(VERILATOR_ROOT)/include/verilated.cpp
VERILATOR_CXX_FILES+= $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
VERILATOR_CXX_FILES+= $(VERILATOR_ROOT)/include/verilated_fst_c.cpp
TEST_CXX_FILES?=$(shell find $(TEST_DIR) -name '*.cpp')

all: $(RTL_SOURCES)

$(RTL_SOURCES):
	$(VERILATOR) $(VERILATOR_OPT) -F $@.txt -top-module $(TOP_MODULE) --Mdir $@_work
	$(MAKE) -C $@_work -f V$(TOP_MODULE).mk
	$(CXX) $(CXX_OPT) -I$@_work $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $@_work/V$(TOP_MODULE)__ALL.a $(CXX_OPT) -o $@_test

clean:
	rm -rf *_work *_test *.vcd *.fst

sim:
	@echo "BUG 1: incomplete implementation of AXI Stream"
	./sources0_test

wave:
	gtkwave sources0_test.fst >/dev/null 2>/dev/null &

# for resouce-util synthesize
RTL_SOURCES=sources.txt
VERIPASS_TOP_MODULE=xlnxstream_2018_3
TOP_MODULE_SYNTH=xlnxstream_2018_3_wrapper
TCLGEN_SRCS=vivado_synth/xlnxstream_2018_3_wrapper.v
SV2V_OUT_FILES+=withtask
CODE_GEN+=withtask.v bug7.v
withtask.v: ${RTL_SOURCES} bug7.instrument.cfg
	${TOOLS} --top ${VERIPASS_TOP_MODULE} -F ${RTL_SOURCES} --config bug7.instrument.cfg --reset "!M_AXIS_ARESETN"

DEPTH_SWEEP_PREFIX+=depth_sweep_bug7
depth_sweep_bug7_d%.v: ${RTL_SOURCES} bug7.instrument.cfg
	${TOOLS} --top ${VERIPASS_TOP_MODULE} -F ${RTL_SOURCES} --config bug7.instrument.cfg --reset "!M_AXIS_ARESETN" --config-override="{\"LOG2_SAMPLE_DEPTH\":$*, \"SV2V_OUTPUT\":\"$@\", \"ILA_OUTPUT\":\"$(basename $@).ila.tcl\"}"
include ../common/Makefile.ILA.rules
