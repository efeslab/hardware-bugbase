all: verilator sw

verilator:
	verilator -cc -F source.txt -top-module fftmain -Wno-TIMESCALEMOD --trace --assert -Wno-PINMISSING -Wno-VLTAG
	cd obj_dir; $(MAKE) -f Vfftmain.mk

sw: verilator
	cd test; $(MAKE)

clean:
	cd test; $(MAKE) clean
	rm -rf *.iq *.raw *.xml obj_dir

sim:
	cd test; $(MAKE) test

wave:
	gtkwave test/*.vcd >/dev/null 2>/dev/null &
