#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <cassert>
#include <verilated_vcd_c.h>
#include <verilated.h>
#include <queue>
#include <map>
#include <tuple>
#include <exception>
#include <csetjmp>
#include <csignal>

#include "Vexample.h"

using namespace std;

const uint64_t psc = 2500; // 2500 ps per cycle
const uint64_t pst = 1250; // 1250 ps per tick (half cycle)
uint64_t timestamp = 0;
double sc_time_stamp() {
    return timestamp;
}
void sc_time_step() {
    timestamp += pst;
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vexample *tb = new Vexample;

    Verilated::traceEverOn(true);
    VerilatedVcdC *trace = new VerilatedVcdC;
    tb->trace(trace, 99);
    trace->open("grayscale.vcd");

	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();


	tb->a = 3;
	tb->b = 2;
	tb->a_valid = 1;
	tb->b_valid = 1;
	tb->eval();
	trace->dump(timestamp-1000);
	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();


	tb->a_valid = 0;
	tb->b_valid = 0;
	tb->eval();
	trace->dump(timestamp-1000);
	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();

	tb->a = 10;
	tb->b = 5;
	tb->a_valid = 0;
	tb->b_valid = 1;
	tb->eval();
	trace->dump(timestamp-1000);
	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();

	tb->a_valid = 1;
	tb->eval();
	trace->dump(timestamp-1000);
	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();

	tb->a = 0;
	tb->b = 0;
	tb->a_valid = 0;
	tb->b_valid = 0;
	tb->eval();
	trace->dump(timestamp-1000);
	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();

	tb->clk = 1;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();
	tb->clk = 0;
	tb->eval();
	trace->dump(timestamp);
	sc_time_step();

	trace->flush();
	trace->close();

	return 0;
}
