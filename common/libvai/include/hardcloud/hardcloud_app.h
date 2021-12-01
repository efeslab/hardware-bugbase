//===--- opae_generic_app.h - AFU Link Interface Implementation --- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.txt for details.
//
//===----------------------------------------------------------------------===//
//
// Generic AFU Link Interface implementation
//
//===----------------------------------------------------------------------===//

#include <vai/fpga.h>
#include <cstring>
#include <deque>
#include <unistd.h>

#include "vai_svc_wrapper.h"

#define CTL_ASSERT_RST           0
#define CTL_DEASSERT_RST         1
#define CTL_START                3
#define CTL_STOP                 7

// csr - memory map
#define CSR_AFU_DSM_BASEL        0x0110
#define CSR_AFU_DSM_BASEH        0x0114
#define CSR_CTL                  0x0118
#define CSR_BASE_BUFFER          0x0120

struct Buffer {
  uint64_t size;
  uint64_t phys;
  volatile uint64_t* virt;
};

class HardcloudApp{
private:
  Buffer dsm;
  VAI_SVC_WRAPPER* fpga;
  std::deque<Buffer> buffers;

  uint64_t csr_offset;
  bool opsim;

  int init();
  int opinit();
  int finish();

public:

  HardcloudApp();
  HardcloudApp(bool opsim);
  ~HardcloudApp();

  void* alloc_buffer(uint64_t size);
  void delete_buffer(void *tgt_ptr);

  uint64_t readCSR(int offset);
  void writeCSR(int offset);

  int begin();
  int end();

  int run();    ///< Return 0 if success
};

