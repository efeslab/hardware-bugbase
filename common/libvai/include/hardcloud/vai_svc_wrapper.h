//
// Copyright (c) 2017, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#ifndef __VAI_SVC_WRAPPER_H__
#define __VAI_SVC_WRAPPER_H__ 1

#include <stdint.h>

#include <vai/fpga.h>
#include <vai/mpf/mpf.h>

typedef class VAI_SVC_WRAPPER SVC_WRAPPER;

class VAI_SVC_WRAPPER
{
  public:
    // The constructor and destructor connect to and disconnect from the FPGA.
    VAI_SVC_WRAPPER();
    ~VAI_SVC_WRAPPER();

    // Any errors in constructor?
    bool isOk(void) const { return is_ok; }

    // Is the hardware simulated with ASE?
    bool hwIsSimulated(void) const { return is_simulated; }

    //
    // Wrap MMIO write and read.
    //
    fpga_result mmioWrite64(uint32_t idx, uint64_t v)
    {
        return vai_afu_mmio_write(vai_conn, idx, v);
    }

    uint64_t mmioRead64(uint32_t idx)
    {
        fpga_result r;
        uint64_t v;

        r = vai_afu_mmio_read(vai_conn, idx, &v);
        if (r != FPGA_OK) return -1;

        return v;
    }

    //
    // Expose allocate and free interfaces that hide the details of
    // the various allocation interfaces.  When VTP is present, large
    // multi-page, virtually contiguous buffers may be allocated.
    // The function returns the virtual address of the buffer and also
    // the I/O (physical) address if ioAddress isn't NULL.
    //
    void* allocBuffer(size_t nBytes, uint64_t* ioAddress = NULL);
    void freeBuffer(void* va);
	fpga_result reset()
	{
		return vai_afu_reset(vai_conn);
	}
    mpf_handle_t mpf_handle;

  protected:
    struct vai_afu_conn *vai_conn;

    bool is_ok;
    bool is_simulated;

  private:
    // Connect to an accelerator
    fpga_result findAndOpenAccel();

    // Is the HW simulated with ASE or real?
    bool probeForASE();
};

#endif //  __VAI_SVC_WRAPPER_H__
