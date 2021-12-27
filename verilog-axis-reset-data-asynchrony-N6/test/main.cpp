#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <cassert>
#include <verilated_fst_c.h>
#include <verilated.h>
#include <queue>
#include <map>
#include <tuple>
#include <exception>
#include <csetjmp>
#include <csignal>

#include "Vtest_axis_async_fifo.h"

using namespace std;


jmp_buf jmp_env;
void sig_handler(int signum) {
    longjmp(jmp_env, 1);
}

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
    Vtest_axis_async_fifo *tb = new Vtest_axis_async_fifo;
    
    Verilated::traceEverOn(true);
    VerilatedFstC *trace = new VerilatedFstC;
    tb->trace(trace, 99);
    string waveform = string(argv[0])+".fst";
    trace->open(waveform.c_str());
    
    
    if (setjmp(jmp_env) == 0) {
        signal(SIGABRT, &sig_handler);
        signal(SIGINT, &sig_handler);
    } else {
        goto save_trace_and_exit;
    }
   
    while (!Verilated::gotFinish()) {
        tb->clk = 1;
        tb->eval();
        trace->dump(timestamp);
        sc_time_step();

        tb->clk = 0;
        tb->eval();
        trace->dump(timestamp);
        sc_time_step();
    }
    delete tb;


save_trace_and_exit:

    trace->flush();
    trace->close();

    exit(EXIT_SUCCESS);
    

}
