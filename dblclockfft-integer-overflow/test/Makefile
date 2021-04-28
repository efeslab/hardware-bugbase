################################################################################
##
## Filename: 	Makefile
##
## Project:	A General Purpose Pipelined FFT Implementation
##
## Purpose:	This programs the build process for the test benches
##		associated with the double clocked FFT project.  These
##	test benches are designed for the size and arguments of the FFT as
##	given by the Makefile in the trunk/sw directory, although they shouldn't
##	be too difficult to modify for other FFT parameters.
##
##	Please note that running these test benches requires access to the
##	*cmem_*.hex files found in trunk/rtl.  They will be linked into this
##	directory as part of the tests.
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
##
## Copyright (C) 2015-2020 Gisselquist Technology, LLC
##
## This program is free software (firmware): you can redistribute it and/or
## modify it under the terms of  the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
## target there if the PDF file isn't present.)  If not, see
## <http://www.gnu.org/licenses/> for a copy.
##
## License:	GPL, v3, as defined and found on www.gnu.org,
##		http://www.gnu.org/licenses/gpl.html
##
##
################################################################################
all: fft_tb

OBJDR:= ../obj_dir
VSRCD = ../hex
TBODR:= ../obj_dir
ifneq ($(VERILATOR_ROOT),)
VERILATOR:=$(VERILATOR_ROOT)/bin/verilator
else
VERILATOR:=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
endif
export	$(VERILATOR)
VROOT   := $(VERILATOR_ROOT)
VDEFS:= $(shell ./vversion.sh)
VINC := -I$(VROOT)/include -I$(OBJDR)/ -I$(TBODR)/
FFTLB:= $(OBJDR)/Vfftmain__ALL.a
VSRCS:= $(VROOT)/include/verilated.cpp $(VROOT)/include/verilated_vcd_c.cpp

tb: fft_tb

fft_tb: fft_tb.cpp twoc.cpp twoc.h fftsize.h $(FFTLB)
	g++ -g $(VINC) $(VDEFS) $< twoc.cpp $(FFTLB) $(VSRCS) -lfftw3 -o $@

.PHONY: HEX
HEX:
	ln -sf $(VSRCD)/*.hex .

test: fft_tb HEX # ifft_tb
	./fft_tb

.PHONY: clean
clean:
	rm -f mpy_tb bitreverse_tb fftstage_tb qtrstage_tb butterfly_tb
	rm -f fftstage_tb fft_tb ifft_tb hwbfly_tb laststage_tb
	rm -rf fft_tb.dbl ifft_tb.dbl
	rm -rf *cmem_*.hex
	rm -rf *.pass *.vcd

include $(VERILATOR_ROOT)/include/verilated.mk
