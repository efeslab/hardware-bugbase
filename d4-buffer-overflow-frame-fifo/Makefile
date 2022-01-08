include ../common/Makefile.env
SIM_SOURCES?=sources-sim.txt
#SIM_SOURCES?=sources.txt
RTL_SOURCES?=sources-veripass.txt
SIM_TOP_MODULE?=axis_fifo_wrapper
RTL_WORK_DIR?=work
TEST_DIR?=test

VERILATOR=../../veripass/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-TIMESCALEMOD -Wno-UNSIGNED -Wno-PINMISSING -Wno-SELRANGE
VERILATOR_OPT+= -trace-fst -trace-structs
VERILATOR_OPT+= -assert -trace-max-array 65536 -trace-max-width 65536
VERILATOR_ROOT=$(CURDIR)/../../veripass/verilator

CXX?= g++
CXX_OPT?=
CXX_OPT+= -g
CXX_OPT+= -I$(VERILATOR_ROOT)/include -I$(RTL_WORK_DIR)
CXX_OPT+= -lz
VERILATOR_CXX_FILES?= $(VERILATOR_ROOT)/include/verilated.cpp
VERILATOR_CXX_FILES+= $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
VERILATOR_CXX_FILES+= $(VERILATOR_ROOT)/include/verilated_fst_c.cpp
TEST_CXX_FILES?=$(shell find $(TEST_DIR) -name '*.cpp')
TEST_RTL_SIMLIB?=$(RTL_WORK_DIR)/V$(SIM_TOP_MODULE)__ALL.a
TEST_BIN?= axis_fifo_test

all: clean verilator sw

verilator:
	$(VERILATOR) $(VERILATOR_OPT) -F $(SIM_SOURCES) -top-module $(SIM_TOP_MODULE) --Mdir $(RTL_WORK_DIR)
	$(MAKE) -C $(RTL_WORK_DIR) -f V$(SIM_TOP_MODULE).mk

sw: verilator
	$(CXX) $(CXX_OPT) $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $(TEST_RTL_SIMLIB) $(CXX_OPT) -o $(TEST_BIN)

clean:
	rm -rf $(RTL_WORK_DIR) $(TEST_BIN) *.vcd *.fst

sim:
	@echo "BUG 1: Bit Splitting Bug"
	./$(TEST_BIN)

wave:
	gtkwave *.fst > /dev/null 2>/dev/null &

# for resource-util synthesize
TOP_MODULE=axis_fifo_wrapper
TOP_MODULE_SYNTH=axis_fifo_wrapper
TCLGEN_SRCS=
SV2V_OUT_FILES+=withtask
CODE_GEN+=withtask.v bug.v

withtask.v: ${RTL_SOURCES} n7.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config n7.instrument.cfg --reset "rst"

DEPTH_SWEEP_PREFIX+=depth_sweep_n7
depth_sweep_n7_d%.v: ${RTL_SOURCES} n7.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config n7.instrument.cfg --reset "rst" --config-override="{\"LOG2_SAMPLE_DEPTH\":$*, \"SV2V_OUTPUT\":\"$@\", \"ILA_OUTPUT\":\"$(basename $@).ila.tcl\"}"
include ../common/Makefile.ILA.rules
