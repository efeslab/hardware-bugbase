PWD=$(shell pwd)
VERILOG_SOURCES = $(wildcard $(PWD)/cores/*.v)
SIM=icarus

TOPLEVEL := fftmain
MODULE   := test

#include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
#include $(COCOTB)/makefiles/Makefile.sim

clean::
	rm -rf *.iq *.raw *.xml sim_build __pycache__
