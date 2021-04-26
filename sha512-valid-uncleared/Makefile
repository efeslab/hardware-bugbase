include ../common/Makefile.env
RTL_SOURCES?=sources.txt
TOP_MODULE?=ccip_std_afu_wrapper
RTL_WORK_DIR?=work
TEST_DIR?=test

VERILATOR?=/home/jcma/verilator/bin/verilator
VERILATOR_OPT?=
VERILATOR_OPT+= -cc -timescale-override 10ps/10ps
VERILATOR_OPT+= -Wno-WIDTH -Wno-LITENDIAN -Wno-UNPACKED -Wno-BLKANDNBLK -Wno-CASEINCOMPLETE \
				-Wno-CASEX -Wno-TIMESCALEMOD -Wno-VLTAG
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
TEST_BIN?= sha512_test

all: clean verilator sw

verilator:
	$(VERILATOR) $(VERILATOR_OPT) -F $(RTL_SOURCES) -top-module $(TOP_MODULE) --Mdir $(RTL_WORK_DIR)
	$(MAKE) -C $(RTL_WORK_DIR) -f V$(TOP_MODULE).mk

sw: verilator
	$(CXX) $(CXX_OPT) $(VERILATOR_CXX_FILES) $(TEST_CXX_FILES) $(TEST_RTL_SIMLIB) -o $(TEST_BIN)

clean:
	rm -rf $(RTL_WORK_DIR) $(TEST_BIN) *.vcd *.fst

sim:
	@echo "BUG 1: Valid Bit Uncleared"
	./$(TEST_BIN)
	@echo "BUG 2: Bit Cast Error"
	@echo "At rtl/sha512_csr.sv:103, bit 42-47 will be ignored. No assertion available."

wave:
	gtkwave *.fst >/dev/null 2>/dev/null &

SV2V_OUT_FILES+=withtask_bug1 withtask_bug2
withtask_bug1.v: ${RTL_SOURCES}
	${FSM_DETECT} --top ${TOP_MODULE} -F ${RTL_SOURCES} \
		-S ccip_std_afu__DOT__uu_sha512_requestor__DOT__rd_state \
		-S ccip_std_afu__DOT__uu_sha512_requestor__DOT__wr_state \
		--tag debug_display_1.1.1 -o tmp.v
	${SV2V} --top ${TOP_MODULE} -f tmp.v --tasksupport --tasksupport-mode=STP \
		--tasksupport-tags=debug_display_1.1.1 \
		--tasksupport-tags=debug_display_1.1.2 \
		-o $@
	rm tmp.v
withtask_bug2.v: ${RTL_SOURCES}
	${FSM_DETECT} --top ${TOP_MODULE} -F ${RTL_SOURCES} -S ccip_std_afu__DOT__uu_sha512_requestor__DOT__rd_state -S ccip_std_afu__DOT__uu_sha512_requestor__DOT__wr_state --tag debug_display_1.1.1 -o tmp.v
	${SV2V} --top ${TOP_MODULE} -f tmp.v --tasksupport --tasksupport-mode=STP \
		--tasksupport-tags=debug_display_1.1.1 \
		--tasksupport-tags=debug_display_2.1.2 \
		--tasksupport-tags=debug_display_2.2.1 \
		-o $@
	rm tmp.v
include ../common/Makefile.rules
