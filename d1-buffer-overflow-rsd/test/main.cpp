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

#include "Vccip_std_afu_wrapper.h"
#include "ccip_std_afu.h"
#include "ccip_test_pkt.h"

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
void sc_time_step_half() {
	timestamp += pst/2;
}

#define ZEROIZE(x) \
    memset(&(x), 0, sizeof((x)))

void zeroize_inputs(Vccip_std_afu_wrapper *tb) {
    ZEROIZE(tb->pClk);
    ZEROIZE(tb->pck_cp2af_softReset);
    ZEROIZE(tb->c0TxAlmFull);
    ZEROIZE(tb->c1TxAlmFull);
    ZEROIZE(tb->c0Rx_rspValid);
    ZEROIZE(tb->c0Rx_mmioRdValid);
    ZEROIZE(tb->c0Rx_mmioWrValid);
    ZEROIZE(tb->c1Rx_rspValid);
    ZEROIZE(tb->c0Rx_hdr);
    ZEROIZE(tb->c0Rx_data);
    ZEROIZE(tb->c1Rx_hdr);
}

void zeroize_extra_bits(Vccip_std_afu_wrapper *tb) {
    tb->pClk &= 0x1;
    tb->pck_cp2af_softReset &= 0x1;
    tb->c0TxAlmFull &= 0x1;
    tb->c1TxAlmFull &= 0x1;
    tb->c0Rx_rspValid &= 0x1;
    tb->c0Rx_mmioRdValid &= 0x1;
    tb->c0Rx_mmioWrValid &= 0x1;
    tb->c1Rx_rspValid &= 0x1;
    tb->c0Tx_valid &= 0x1;
    tb->c1Tx_valid &= 0x1;
    tb->c2Tx_mmioRdValid &= 0x1;
    tb->c2Tx_hdr &= 0x1ff;
    tb->c0Rx_hdr &= 0xfffffff;
    tb->c1Rx_hdr &= 0xfffffff;
    tb->c0Tx_hdr[2] &= 0x1ff;
    tb->c1Tx_hdr[2] &= 0x7fff;
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vccip_std_afu_wrapper *tb = new Vccip_std_afu_wrapper;

    Verilated::traceEverOn(true);
    VerilatedFstC *trace = new VerilatedFstC;
    tb->trace(trace, 99);
    trace->open("grayscale.fst");

    vector<pkt_entry*> long_term, c0tx_listen, c1tx_listen, c2tx_listen;
    priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> control;
    priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> c0rx_issue;
    priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> c1rx_issue;
    string file = "test/config.txt";
    parse_config(file, control, c0rx_issue, c1rx_issue, c0tx_listen, c1tx_listen, c2tx_listen);

    if (setjmp(jmp_env) == 0) {
        signal(SIGABRT, &sig_handler);
        signal(SIGINT, &sig_handler);
    } else {
        goto save_trace_and_exit;
    }

    while (!Verilated::gotFinish()) {

        if (c0tx_listen.empty() && c1tx_listen.empty()
                && c2tx_listen.empty() && control.empty() && c0rx_issue.empty()
                && c1rx_issue.empty()) {
            break;
        }

		zeroize_inputs(tb);

        // check
        if (!control.empty()) {
            // check softreset
            // if there's anything, finish reset and continue
            pkt_entry *ent = control.top();
            control.pop();

            if (ent->kind == pkt_entry::PKT_SOFTRESET) {
                pkt_soft_reset *sr_ent = (pkt_soft_reset *) ent;
                uint64_t end_timestamp = sr_ent->timestamp + sr_ent->length;

                tb->pck_cp2af_softReset = 1;
                while (timestamp < end_timestamp) {
                    tb->pClk = 1;
					tb->pClkDiv2 = !tb->pClkDiv2;
                    tb->eval();
                    trace->dump(timestamp);
                    sc_time_step();
                    tb->pClk = 0;
                    tb->eval();
                    trace->dump(timestamp);
                    sc_time_step();
                }
                tb->pck_cp2af_softReset = 0;

                continue;
            } else if (ent->kind == pkt_entry::PKT_ALMFULL) {
                long_term.push_back(ent);
            }
        }

        if (!long_term.empty()) {
            for (int i = 0; i < long_term.size(); i++) {
                pkt_entry *ent = long_term[i];
                assert(ent->kind == pkt_entry::PKT_ALMFULL);
                pkt_almfull *almfull_ent = (pkt_almfull *) ent;
                if (almfull_ent->timestamp + almfull_ent->length < timestamp) {
                    long_term.erase(long_term.begin()+i);
                    i--;
                } else {
                    if (almfull_ent->timestamp <= timestamp) {
                        if (almfull_ent->channel == 0) {
                            tb->c0TxAlmFull = 1;
                        } else if (almfull_ent->channel == 1) {
                            tb->c1TxAlmFull = 1;
                        } else {
                            cerr << "invalid channel" << endl;
                            abort();
                        }
                    }
                }
            }
        }

        if (!c0rx_issue.empty()) {
            // check pending packets at c0rx
            pkt_entry *ent = c0rx_issue.top();
            assert(ent->timestamp >= timestamp);

            if (ent->timestamp == timestamp) {
                c0rx_issue.pop();
                if (ent->kind == pkt_entry::PKT_MMIO_RD) {
                    pkt_mmio_rd *mmio_rd_ent = (pkt_mmio_rd *) ent;
                    memcpy(&tb->c0Rx_hdr, &mmio_rd_ent->hdr, sizeof(tb->c0Rx_hdr));
                    tb->c0Rx_mmioRdValid = 1;
                } else if (ent->kind == pkt_entry::PKT_MMIO_WR) {
                    pkt_mmio_wr *mmio_wr_ent = (pkt_mmio_wr *) ent;
                    memcpy(&tb->c0Rx_hdr, &mmio_wr_ent->hdr, sizeof(tb->c0Rx_hdr));
                    tb->c0Rx_data[0] = mmio_wr_ent->value & 0xffffffff;
                    tb->c0Rx_data[1] = (mmio_wr_ent->value >> 32) & 0xffffffff;
                    tb->c0Rx_mmioWrValid = 1;
                } else if (ent->kind == pkt_entry::PKT_MEM_RD) {
                    pkt_mem_rd *mem_rd_ent = (pkt_mem_rd *) ent;
                    memcpy(&tb->c0Rx_hdr, &mem_rd_ent->hdr, sizeof(tb->c0Rx_hdr));
                    memcpy(&tb->c0Rx_data, &mem_rd_ent->value, sizeof(tb->c0Rx_data));
                    tb->c0Rx_rspValid = 1;
                } else {
                    cerr << "wrong packet type at c0rx" << endl;
                    abort();
                }
            }
        }

        if (!c1rx_issue.empty()) {
            // check pending packets at c1rx
            pkt_entry *ent = c1rx_issue.top();
            assert(ent->timestamp >= timestamp);

            if (ent->timestamp == timestamp) {
                c1rx_issue.pop();
                if (ent->kind == pkt_entry::PKT_MEM_WR) {
                    pkt_mem_wr *mem_wr_ent = (pkt_mem_wr *) ent;
                    memcpy(&tb->c1Rx_hdr, &mem_wr_ent->hdr, sizeof(tb->c1Rx_hdr));
                    tb->c1Rx_rspValid = 1;
                } else {
                    cerr << "wrong packet type at c0rx" << endl;
                    abort();
                }
            }
        }

        if (!c0tx_listen.empty()) {
            // check incoming packets at c0tx
            if (tb->c0Tx_valid) {
                t_ccip_c0tx_MemHdr hdr;
                memcpy(&hdr, &tb->c0Tx_hdr, sizeof(hdr));

                cout << "c0tx received, addr=" << std::hex << hdr.address << endl;

                bool matched = false;

                for (int i = 0; i < c0tx_listen.size(); i++) {
                    assert(c0tx_listen[i]->kind == pkt_entry::PKT_MEM_RD);
                    pkt_mem_rd *ent = (pkt_mem_rd *) c0tx_listen[i];
                    if (ent->expected_address == hdr.address) {
                        c0tx_listen.erase(c0tx_listen.begin()+i);
                        ent->hdr.mdata = hdr.mdata;
                        if (ent->timer_kind == pkt_entry::PKT_TIMER_DELAY) {
                            ent->timestamp += timestamp;
                        }
                        c0rx_issue.push(ent);
                        matched = true;
                        break;
                    }
                }

                if (!matched)
                    abort();

            }
        }

        if (!c1tx_listen.empty()) {
            // check incoming packets at c0tx
            if (tb->c1Tx_valid) {
                t_ccip_c1tx_MemHdr memwr_hdr;
                t_ccip_c1tx_FenceHdr fence_hdr;
                memcpy(&memwr_hdr, &tb->c1Tx_hdr, sizeof(memwr_hdr));
                memcpy(&fence_hdr, &tb->c1Tx_hdr, sizeof(fence_hdr));

                if (memwr_hdr.req_type != eRSP_WRFENCE) {
                    for (int i = 0; i < c1tx_listen.size(); i++) {
                        assert(c1tx_listen[i]->kind == pkt_entry::PKT_MEM_WR);
                        pkt_mem_wr *ent = (pkt_mem_wr *) c1tx_listen[i];
                        if (ent->expected_address == memwr_hdr.address) {
                            c1tx_listen.erase(c1tx_listen.begin()+1);
                            ent->hdr.mdata = memwr_hdr.mdata;
                            if (ent->timer_kind == pkt_entry::PKT_TIMER_DELAY) {
                                ent->timestamp += timestamp;
                            }
                            c1rx_issue.push(ent);
                            break;
                        }
                    }
                } else if (memwr_hdr.req_type == eRSP_WRFENCE) {
                    // TODO
                    cerr << "fence is not supported";
                    abort();
                }
            }
        }

        if (!c2tx_listen.empty()) {
            // TODO
        }

        // NOTE: This step is important, because:
        // 1. For structs like t_ccip_c0tx_MemHdr, where a few bits are not used at
        //    the end of the struct, C++ DOES NOT promise that these bits are filled
        //    by 0.
        // 2. Verilator ASSUMES these bits are 0.
        zeroize_extra_bits(tb);
		tb->eval();
		trace->dump(timestamp);
		sc_time_step_half();

        tb->pClk = 1;
        tb->pClkDiv2 = !tb->pClkDiv2;
        tb->eval();
        trace->dump(timestamp);
        sc_time_step();

        tb->pClk = 0;
        tb->eval();
        trace->dump(timestamp);
        sc_time_step_half();
    }

save_trace_and_exit:

    trace->flush();
    trace->close();

    exit(EXIT_SUCCESS);
}
