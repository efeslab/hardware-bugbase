all: clean verilator

dep:
	git clone https://github.com/openhwgroup/cv32e40p --recurse ./cv32e40p; cd ./cv32e40p; git checkout 916d92afc6bbc27b7ab65c503043982e1b6e3ab0
	git clone https://github.com/pulp-platform/fpnew --recurse ./cv32e40p/rtl/fpnew; cd ./cv32e40p/rtl/fpnew; git checkout f108dfdd84f7c24dcdefb35790fafb3905bce552

verilator: dep
	verilator --cc --sv --exe \
		--trace \
		--Wno-lint --Wno-UNOPTFLAT \
		--Wno-MODDUP --top-module tb_top_verilator \
		tb/core/tb_top_verilator.sv tb/core/cv32e40p_tb_wrapper.sv tb/core/mm_ram.sv tb/core/dp_ram.sv \
	    -f cv32e40p_temp_manifest.flist \
		tb/core/tb_top_verilator.cpp --Mdir cobj_dir \
		-CFLAGS "-std=gnu++11 -O2 -DVCD_TRACE" \
		-Wno-BLKANDNBLK
	$(MAKE) -C cobj_dir -f Vtb_top_verilator.mk
	cp cobj_dir/Vtb_top_verilator testbench_verilator

clean:
	rm -rf cobj_dir cv32e40p *.vcd *.fst testbench_verilator memory_dump.bin

sim:
	@echo "BUG 1: DIV takes 36 cycles"
	./testbench_verilator +vcd +firmware=riscv_branch_div.hex
	@echo "-----------------------------"
	@echo "'make wave' and look around TOP.tb_top_verilator.cv32e40p_tb_wrapper_i.ram_i.ram_instr_valid at 1130ps"


wave:
	gtkwave *.vcd >/dev/null 2>/dev/null &
