include ../common/Makefile.env
RTL_SOURCES?=sources.txt
TOP_MODULE?=sdspi
RTL_WORK_DIR?=work
TEST_DIR?=bench/cpp

VERILATOR?=/home/jcma/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-TIMESCALEMOD
VERILATOR_OPT+= -trace -trace-structs
VERILATOR_OPT+= -assert -trace-max-array 65536 -trace-max-width 65536
VERILATOR_ROOT?=$(shell $(VERILATOR) -getenv VERILATOR_ROOT)

CXX?= g++
CXX_OPT?=
CXX_OPT+= -g
CXX_OPT+= -I$(VERILATOR_ROOT)/include -I$(RTL_WORK_DIR)
CXX_OPT+= -lz
VERILATOR_CXX_FILES?= $(VERILATOR_ROOT)/include/verilated.cpp
VERILATOR_CXX_FILES+= $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
VERILATOR_CXX_FILES+= $(VERILATOR_ROOT)/include/verilated_fst_c.cpp
TEST_CXX_FILES?=$(shell find $(TEST_DIR) -name '*.cpp')
TEST_RTL_SIMLIB?=$(RTL_WORK_DIR)/V$(TOP_MODULE)__ALL.a
TEST_BIN?= sdspi_tb

all: clean verilator sw sdcard

sdcard:
	qemu-img create -f raw sdcard.img 128M

verilator:
	$(VERILATOR) $(VERILATOR_OPT) -F $(RTL_SOURCES) -top-module $(TOP_MODULE) --Mdir $(RTL_WORK_DIR)
	$(MAKE) -C $(RTL_WORK_DIR) -f V$(TOP_MODULE).mk

sw: verilator
	$(CXX) $(CXX_OPT) $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $(TEST_RTL_SIMLIB) -o $(TEST_BIN)

clean:
	rm -rf $(RTL_WORK_DIR) $(TEST_BIN) *.vcd *.fst *.img

sim:
	@echo "BUG 1: Press Ctrl-C, then take a look of waveform. The sdcard clock o_sclk is not generated. The root cause is at rtl/llsdspi.v:182."
	./$(TEST_BIN)

wave:
	gtkwave trace.vcd > /dev/null 2>/dev/null &

# for resource-util synthesize
TOP_MODULE_SYNTH=sdspi_wrapper
TCLGEN_SRCS=vivado_synth/sdspi_wrapper.v
TCL_TEMPLATE=tcl.template
SV2V_OUT_FILES+=withtask
CODE_GEN+=withtask.v bug9.v

withtask.v: ${RTL_SOURCES} bug9.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config bug9.instrument.cfg --reset "!i_bus_grant"

DEPTH_SWEEP_PREFIX+=depth_sweep_bug9
depth_sweep_bug9_d%.v: ${RTL_SOURCES} bug9.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config bug9.instrument.cfg --reset "!i_bus_grant" --config-override="{\"LOG2_SAMPLE_DEPTH\":$*, \"SV2V_OUTPUT\":\"$@\", \"ILA_OUTPUT\":\"$(basename $@).ila.tcl\"}"
include ../common/Makefile.ILA.rules
