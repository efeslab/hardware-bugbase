PWD=$(shell pwd)
VERILOG_SOURCES = $(wildcard $(PWD)/cores/*.v)
SIM=verilator

TOPLEVEL := fftmain
MODULE   := test

#include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
#include $(COCOTB)/makefiles/Makefile.sim

clean::
	rm -rf *.iq *.raw *.xml sim_build __pycache__

sim: all

wave:
	gtkwave sim_build/waveform.vcd >/dev/null 2>/dev/null &
