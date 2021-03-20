RTL_SOURCES?=sources0 sources1
TOP_MODULE?=testbench
TEST_DIR?=test

VERILATOR?=/home/jcma/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc -timescale-override 10ps/10ps
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-PINMISSING
VERILATOR_OPT+= -trace -trace-structs
VERILATOR_OPT+= -assert -trace-max-array 65536 -trace-max-width 65536
VERILATOR_ROOT?=$(shell $(VERILATOR) -getenv VERILATOR_ROOT)

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
	$(CXX) $(CXX_OPT) -I$@_work $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $@_work/V$(TOP_MODULE)__ALL.a -o $@_test

clean:
	rm -rf *_work *_test *.vcd *.fst

sim:
	@echo "BUG 1: incomplete implementation of AXI"
	./sources0_test
	@echo "BUG 2: incomplete implementation of AXI"
	./sources1_test

wave:
	gtkwave sources0_test.vcd >/dev/null 2>/dev/null &
	gtkwave sources1_test.vcd >/dev/null 2>/dev/null &
