all: clean run

dep:
	git clone -b add_riscv_rand_instr_test_0 https://github.com/GTumbush/core-v-verif

run: dep
	cd core-v-verif/cv32/sim/core; VERI_FLAGS="+vcd" $(MAKE) verilate

clean:
	rm -rf core-v-verif *.vcd *.fst

sim:
	@echo "BUG 1: DIV takes 36 cycles"
	cd core-v-verif/cv32/sim/core; VERI_FLAGS="+vcd" $(MAKE) custom CUSTOM_PROG=riscv_branch_div
	cp core-v-verif/cv32/sim/core/verilator_tb.vcd .
	@echo "-----------------------------"
	@echo "'make wave' and look around TOP.tb_top_verilator.cv32e40p_tb_wrapper_i.ram_i.ram_instr_valid at 1130ps"


wave:
	gtkwave *.vcd >/dev/null 2>/dev/null &
