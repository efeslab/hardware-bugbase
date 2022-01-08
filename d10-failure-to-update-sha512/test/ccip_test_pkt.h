#ifndef _CCIP_TEST_PKT_H_
#define _CCIP_TEST_PKT_H_

#include <inttypes.h>
#include <vector>
#include <queue>
#include <cstring>
#include "ccip_std_afu.h"

using namespace std;

struct pkt_entry {
    enum pkt_kind {
        PKT_SOFTRESET,
        PKT_ALMFULL,
        PKT_MMIO_RD,
        PKT_MMIO_WR,
        PKT_MEM_RD,
        PKT_MEM_WR,
        PKT_FENCE
    } kind;

    enum pkt_timer_kind {
        PKT_TIMER_CONST,
        PKT_TIMER_DELAY
    };

    uint64_t timestamp;
    pkt_entry(pkt_kind _kind) : kind(_kind) {}
};

struct pkt_soft_reset : public pkt_entry {
    uint64_t length;

    pkt_soft_reset() : pkt_entry(PKT_SOFTRESET) {}
};

struct pkt_almfull : public pkt_entry {
    uint64_t channel;
    uint64_t length;

    pkt_almfull() : pkt_entry(PKT_ALMFULL) {}
};

struct pkt_mmio_rd : public pkt_entry {
    t_ccip_c0rx_MmioHdr hdr;
    uint64_t expected_value;

    pkt_mmio_rd() : pkt_entry(PKT_MMIO_RD) {}
};

struct pkt_mmio_wr : public pkt_entry {
    t_ccip_c0rx_MmioHdr hdr;
    uint64_t value;

    pkt_mmio_wr() : pkt_entry(PKT_MMIO_WR) {}
};

struct pkt_mem_rd : public pkt_entry {
    uint64_t expected_address:42;

    pkt_timer_kind timer_kind;
    t_ccip_c0rx_MemHdr hdr;
    uint64_t value[8];

    pkt_mem_rd() : pkt_entry(PKT_MEM_RD) {
        memset(&hdr, 0, sizeof(hdr));
    }
};

struct pkt_mem_wr : public pkt_entry {
    uint64_t expected_address:42;

    pkt_timer_kind timer_kind;
    t_ccip_c1rx_MemHdr hdr;

    pkt_mem_wr() : pkt_entry(PKT_MEM_WR) {
        memset(&hdr, 0, sizeof(hdr));
    }
};

struct pkt_fence : public pkt_entry {
    t_ccip_c1rx_FenceHdr hdr;

    pkt_fence() : pkt_entry(PKT_FENCE) {
        memset(&hdr, 0, sizeof(hdr));
    }
};

struct pkt_entry_ptr_compare {
    bool operator()(const pkt_entry *left, const pkt_entry *right) {
        return left->timestamp > right->timestamp;
    }
};

void parse_config(string &config,
        priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> &control,
        priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> &c0rx_issue,
        priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> &c1rx_issue,
        vector<pkt_entry*> &c0tx_listen,
        vector<pkt_entry*> &c1tx_listen,
        vector<pkt_entry*> &c2tx_listen);

#endif
