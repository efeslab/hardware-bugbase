#include <stdlib.h>
#include <stdio.h>
#include <verilated_vcd_c.h>
#include "Vccip_std_afu.h"
#include "verilated.h"

double sc_time_stamp() {
  return 0;
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vccip_std_afu *tb = new Vccip_std_afu;

    Verilated::traceEverOn(true);

    VerilatedVcdC *trace;
    trace = new VerilatedVcdC;
    tb->trace(trace, 99);
    trace->open("shit.vcd");

    int tickcount = 0;

    for (int i = 0; i < 10; i++) {
        tickcount++;
        tb->pClk = 1;
        tb->eval();
        trace->dump(10*tickcount);
        tb->pClk = 0;
        tb->eval();
        trace->dump(10*tickcount + 5);
    }

    trace->dump(10*tickcount+10);
    trace->flush();

    exit(EXIT_SUCCESS);
}
