include ../common/Makefile.env
RTL_SOURCES?=sources.txt
#RTL_SOURCES?=instrumented.txt
TOP_MODULE?=ccip_std_afu_wrapper
RTL_WORK_DIR?=work
TEST_DIR?=test

VERILATOR?=/home/jcma/veripass/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-TIMESCALEMOD -Wno-PINMISSING -Wno-ALWCOMBORDER -Wno-VLTAG
VERILATOR_OPT+= -trace-fst -trace-structs -comp-limit-syms 0
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
TEST_BIN?= grayscale_mux4_test

all: clean verilator sw

verilator:
	$(VERILATOR) $(VERILATOR_OPT) -F $(RTL_SOURCES) -top-module $(TOP_MODULE) --Mdir $(RTL_WORK_DIR)
	$(MAKE) -C $(RTL_WORK_DIR) -f V$(TOP_MODULE).mk

sw: verilator
	$(CXX) $(CXX_OPT) $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $(TEST_RTL_SIMLIB) -o $(TEST_BIN)

clean:
	rm -rf $(RTL_WORK_DIR) $(TEST_BIN) *.vcd *.fst

sim:
	@echo "BUG 1: Singal Conflict"
	./$(TEST_BIN) test/config-1.txt grayscale_mux8_bug1.fst
	@echo "-------------------"
	@echo "BUG 2: Buffer Overflow"
	./$(TEST_BIN) test/config-2.txt grayscale_mux8_bug2.fst

wave:
	gtkwave grayscale_mux8_bug1.fst > /dev/null 2>/dev/null &
	gtkwave grayscale_mux8_bug2.fst > /dev/null 2>/dev/null &

SV2V_OUT_FILES+=withtask
# bug5: Optimus-BufferOverflow and Optimus-SignalConflict
CODE_GEN+=withtask.v bug5_step4.v
withtask.v: ${RTL_SOURCES} bug5.instrument.cfg
	${TOOLS} --top ${TOP_MODULE} -F ${RTL_SOURCES} --config bug5.instrument.cfg --reset ccip_std_afu__DOT__ccip_mux_U0__DOT__reset
include ../common/Makefile.STP.rules
