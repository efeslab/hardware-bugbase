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

#include "Vfadd.h"

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

uint32_t op1[8] = {
    0x3f800000,
    0x3f800000,
    0xbf800000,
    0xbf800000,
    0x00000000,
    0x3f800000,
    0x00000000,
    0x00800000
};

uint32_t op2[8] = {
    0x3f800000,
    0xbf800000,
    0xbf800000,
    0x3f800000,
    0x3f800000,
    0x00000000,
    0x00000000,
    0x02800000
};

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vfadd *tb = new Vfadd;
    int outcnt = 0;

    Verilated::traceEverOn(true);
    VerilatedFstC *trace = new VerilatedFstC;
    tb->trace(trace, 99);
    trace->open("fadd.fst");

    if (setjmp(jmp_env) == 0) {
        signal(SIGABRT, &sig_handler);
        signal(SIGINT, &sig_handler);
    } else {
        goto save_trace_and_exit;
    }

    tb->rst = 0;
    tb->op1 = 0;
    tb->op2 = 0;
    tb->clk = 0;
    tb->rst = 1;
    tb->en = 0;
    tb->eval();

    tb->clk = 1;
    tb->eval();
    sc_time_step();
    tb->clk = 0;
    tb->eval();
    sc_time_step();

    tb->rst = 0;
    tb->clk = 1;
    tb->eval();
    sc_time_step();
    tb->clk = 0;
    tb->eval();
    sc_time_step();

    tb->en = 1;
    for (int i = 0; i < 8; i++) {
        if (tb->res_val_correct) {
            assert(tb->res_val_buggy);
            cout << "--------------------------" << endl;
            cout << "correct: " << *(float*)&op1[outcnt] << " + " << *(float*)&op2[outcnt] << " = " << *(float*)&tb->res_correct << endl;
            cout << "buggy:   " << *(float*)&op1[outcnt] << " + " << *(float*)&op2[outcnt] << " = " << *(float*)&tb->res_buggy << endl;
            outcnt++;
        }

        tb->op1 = op1[i];
        tb->op2 = op2[i];
        tb->clk = 1;
        tb->eval();
        sc_time_step();
        tb->clk = 0;
        tb->eval();
        sc_time_step();
    }

    tb->en = 0;
    for (int i = 0; i < 10; i++) {
        if (tb->res_val_correct) {
            assert(tb->res_val_buggy);
            cout << "--------------------------" << endl;
            cout << "correct: " << *(float*)&op1[outcnt] << " + " << *(float*)&op2[outcnt] << " = " << *(float*)&tb->res_correct << endl;
            cout << "buggy:   " << *(float*)&op1[outcnt] << " + " << *(float*)&op2[outcnt] << " = " << *(float*)&tb->res_buggy << endl;
            outcnt++;
        }

        tb->clk = 1;
        tb->eval();
        sc_time_step();
        tb->clk = 0;
        tb->eval();
        sc_time_step();
    }

save_trace_and_exit:

    trace->flush();
    trace->close();

    exit(EXIT_SUCCESS);
}
