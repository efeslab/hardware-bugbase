#ifndef _CCIP_STD_AFU_H_
#define _CCIP_STD_AFU_H_

extern "C" {

#include <inttypes.h>

enum t_ccip_c0_req {
    eREQ_RDLINE_I = 0,
    eREQ_RDLINE_S = 1
};

enum t_ccip_c1_req {
    eREQ_WRLINE_I = 0,
    eREQ_WRLINE_M = 1,
    eREQ_WRPUSH_I = 2,
    eREQ_WRFENCE = 4
};

enum t_ccip_c0_rsp {
    eRSP_RDLINE = 0,
    eRSP_UMSG = 4
};

enum t_ccip_c1_rsp {
    eRSP_WRLINE = 0,
    eRSP_WRFENCE = 4
};

enum t_ccip_vc {
    eVC_VA = 0,
    eVC_VL0 = 1,
    eVC_VH0 = 2,
    eVC_VH1 = 3
};

enum t_ccip_clLen {
    eCL_LEN_1 = 0,
    eCL_LEN_2 = 1,
    eCL_LEN_4 = 3
};

struct t_ccip_c0tx_MemHdr {
    // first QWORD
    uint64_t mdata:16;
    uint64_t address:42;
    uint64_t rsvd0:6;
    // second QWORD
    uint32_t req_type:4;
    uint32_t cl_len:2;
    uint32_t rsvd1:2;
    uint32_t vc_sel:2;
};

struct t_ccip_c1tx_MemHdr {
    // first QWORD
    uint64_t mdata:16;
    uint64_t address:42;
    uint64_t rsvd0:6;
    // second QWORD
    uint32_t req_type:4;
    uint32_t cl_len:2;
    uint32_t rsvd1:1;
    uint32_t sop:1;
    uint32_t vc_sel:2;
    uint32_t rsvd2:6;
};

struct t_ccip_c1tx_FenceHdr {
    // first QWORD
    uint64_t mdata:16;
    uint64_t rsvd0:48;
    // second QWORD
    uint32_t req_type:4;
    uint32_t rsvd1:4;
    uint32_t vc_sel:2;
    uint32_t rsvd2:6;
};

struct t_ccip_c0rx_MemHdr {
    uint32_t mdata:16;
    uint32_t resp_type:4;
    uint32_t cl_num:2;
    uint32_t rsvd0:2;
    uint32_t hit_miss:1;
    uint32_t rsvd1:1;
    uint32_t vc_used:2;
};

struct t_ccip_c1rx_MemHdr {
    uint32_t mdata:16;
    uint32_t resp_type:4;
    uint32_t cl_num:2;
    uint32_t rsvd0:1;
    uint32_t format:1;
    uint32_t hit_miss:1;
    uint32_t rsvd1:1;
    uint32_t vc_used:2;
};

struct t_ccip_c1rx_FenceHdr {
    uint32_t mdata:16;
    uint32_t resp_type:4;
    uint32_t rsvd0:8;
};

struct t_ccip_c0rx_MmioHdr {
    uint32_t tid:9;
    uint32_t rsvd:1;
    uint32_t length:2; // 4B: '00, 8B: '01
    uint32_t address:16;
};

struct t_ccip_c2tx_MmioHdr {
    uint32_t tid:9;
};

}

#endif
