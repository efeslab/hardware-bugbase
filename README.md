# A Hardware Bug Database
### Bit Splitting
For example, sometimes it's not correct to assign a 25-bit wire to a 14-bit one.

#### [sha512-valid-uncleared](https://github.com/efeslab/hardware-bugbase/blob/master/sha512-valid-uncleared/Makefile) Bug 2
This bug is a bit splitting problem in the example implementation of [SHA512](https://github.com/omphardcloud/hardcloud/tree/master/samples/sha512) of [HardCloud](https://omphardcloud.github.io/) and we don't have a testbench for it. In this bug, a 64-bit byte address (BA) is converted to a 42-bit cacheline address (CA). The correct convertion is `int42(BA >> 6)`, the buggy code is `int42(BA) >> 6`, which causes some bits in the byte address being ignored.

### Propagation of Unknown Signals
No such bug yet.

### Forget to Set a Bit
#### [sha512-valid-uncleared](https://github.com/efeslab/hardware-bugbase/blob/master/sha512-valid-uncleared/Makefile) Bug 1
This is a bug in the example implementation of [SHA512](https://github.com/omphardcloud/hardcloud/tree/master/samples/sha512) of [HardCloud](https://omphardcloud.github.io/). After finishing the computation, the circuit writes a "status memory" indicating the finish of the task. However, the circuit forget to unser the valid bit of the "sending" packet, causing a lot of memory write requests on the same address to be issued.

### Miss a Corner Case
#### [xilinx-axi-lite-incomplete-implementation](https://github.com/efeslab/hardware-bugbase/tree/master/xilinx-axi-lite-incomplete-implementation) Bug 1 and Bug 2
There are two bugs in this directory. These bugs are discovered by [zipcpu](https://zipcpu.com/formal/2018/12/28/axilite.html) with formal methods. These bugs are in Xilinx's template implementation of AXI-lite interface, which causes data loss.

#### [xilinx-axi-stream-incomplete-implementation](https://github.com/efeslab/hardware-bugbase/tree/master/xilinx-axi-stream-incomplete-implementation)
This bug is discovered by [zipcpu](https://zipcpu.com/dsp/2020/04/20/axil2axis.html) with formal methods. Like the previous one, it is in Xilinx's template implementation of AXI-stream interface, which causes data loss.

#### [sssp-fsm-error](https://github.com/efeslab/hardware-bugbase/tree/master/sssp-fsm-error)
This bug is a FSM design error in a [single source shortest path](https://github.com/efeslab/optimus-intel-fpga-bbb/tree/master/samples/tutorial/vai_sssp) graph accelerator. This accelerator firstly reads graph vertices from memory, then reads edges. Due to a design error, the circuit may consider the first edge as a vertices in some rare cases.

### Buffer Overflow
#### [reed-solomon-decoder-buffer-overwrite](https://github.com/efeslab/hardware-bugbase/tree/master/reed-solomon-decoder-buffer-overwrite)
This bug is an overflow of a write-combining buffer in the example implementation of [reed solomon decoder](https://github.com/omphardcloud/hardcloud/tree/master/samples/reed_solomon_decoder) of [HardCloud](https://omphardcloud.github.io/). The reed solomon decoder core generate 1 byte at a time, and when 64 bytes are generated, the DMA logic writes it to memory as a cacheline. However, when CCIP tx channel 1 is almfull for a long time, this buffer may be overflow.
* This bug is also a back pressure related one.

#### [sidebuf-overflow-conflict](https://github.com/efeslab/hardware-bugbase/tree/master/sidebuf-overflow-conflict) Bug 2
This bug is a buffer overflow in [Optimus](https://github.com/optimus-hypervisor), an hypervisor for shared-memory FPGAs. In the CCIP interface, when `almfull` is asserted by the FPGA shell, the user logic can only send 8 extra packets. However, in this case, the logic is too complex that the packet generation may not stop within 8 cycles (each cycle may have an extra packet), so we store the extra packets in a "side buffer" (in order to avoid the latency of a fifo). Unfortunately, this buffer is too small that may overflow. 

#### [grayscale-fifo-overflow](https://github.com/efeslab/hardware-bugbase/tree/master/grayscale-fifo-overflow)
This bug is a buffer overflow in an example implementation of [grayscale image processing](https://github.com/omphardcloud/hardcloud/tree/master/samples/grayscale) of [HardCloud](https://omphardcloud.github.io/). When `almfull` is asserted on TxC1 channel (which issues write requests) but not asserted on TxC0 channel (which issues read requests), the circuit will keep reading from the memory, thus overflowing a fifo.
* This bug is also a back pressure related one.

### Integer Overflow
#### [dblclockftt-integer-overflow](https://github.com/efeslab/hardware-bugbase/tree/master/dblclockfft-integer-overflow) Bug 2
This bug is originated from https://github.com/ZipCPU/dblclockfft/issues/5. This project is a [generic pipelined FFT core generator](https://github.com/ZipCPU/dblclockfft) designed by [zipcpu](https://zipcpu.com). According to the discussion, it's a integer overflow problem which occurs inside the convround module. Due to the integer overflow, the fft core does not always generate the correct result.



### Interface Issues Between Modules

### Misindexing
#### [fadd-misindexing](https://github.com/efeslab/hardware-bugbase/tree/master/fadd-misindexing)
This bug is a misindexing provided by Brendan West <westbl@umich.edu>. At the buggy place, the correct index is `N-E-1`, and the buggy index is `N-E`.

### Multi-Path Merge Problem

### Dead Lock

### Singed/Unsigned Inconsistency

### Endian Problem

### Back Pressure
#### [reed-solomon-decoder-buffer-overwrite](https://github.com/efeslab/hardware-bugbase/tree/master/reed-solomon-decoder-buffer-overwrite)
* As described above.

#### [grayscale-fifo-overflow](https://github.com/efeslab/hardware-bugbase/tree/master/grayscale-fifo-overflow)
* As described above.

### Signal Conflict
#### [sidebuf-overflow-conflict](https://github.com/efeslab/hardware-bugbase/tree/master/sidebuf-overflow-conflict) Bug 1
We talked about the side buffer previously. When `almfull` is deasserted, it's possible that side buffer and user logic both have a packet to send, which may cause a conflict. In this implementation, the packet from user logic is ignored (which is incorrect).

### Performance Related
#### [cv32-div-too-long](https://github.com/efeslab/hardware-bugbase/tree/master/cv32-div-too-long)
This bug is from https://github.com/openhwgroup/cv32e40p/issues/434. The project is as open source RISC-V core from ETHZ called [cv32e40p](https://github.com/openhwgroup/cv32e40p/issues/434). In some special branch combinations, a DIV may take 36 cycles, which is way more than expected.
