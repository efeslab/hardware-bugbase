RTL_SOURCES?=sources.txt
TOP_MODULE?=fadd
RTL_WORK_DIR?=work
TEST_DIR?=test

VERILATOR?=/home/jcma/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-TIMESCALEMOD
VERILATOR_OPT+= -trace-fst -trace-structs
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
TEST_BIN?= fadd_test

all: clean verilator sw

verilator:
	$(VERILATOR) $(VERILATOR_OPT) -F $(RTL_SOURCES) -top-module $(TOP_MODULE) --Mdir $(RTL_WORK_DIR)
	$(MAKE) -C $(RTL_WORK_DIR) -f V$(TOP_MODULE).mk

sw: verilator
	$(CXX) $(CXX_OPT) $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $(TEST_RTL_SIMLIB) -o $(TEST_BIN)

clean:
	rm -rf $(RTL_WORK_DIR) $(TEST_BIN) *.vcd *.fst

sim:
	@echo "BUG 1: Bit Splitting Bug"
	./$(TEST_BIN)

wave:
	gtkwave grayscale_mux8_bug1.fst > /dev/null 2>/dev/null &
	gtkwave grayscale_mux8_bug2.fst > /dev/null 2>/dev/null &
