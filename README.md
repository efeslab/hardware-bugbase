# A Hardware Bug Database
### Bit Splitting
For example, sometimes it's not correct to assign a 25-bit wire to a 14-bit one. No such bug yet.

### Propagation of Unknown Signals
No such bug yet.

### Forget to Set a Bit
No such bug yet.

### Miss a Corner Case
#### [xilinx-axi-lite-incomplete-implementation](https://github.com/efeslab/hardware-bugbase/tree/master/xilinx-axi-lite-incomplete-implementation) Bug 1 and Bug 2
There are two bugs in this directory. These bugs are discovered by [zipcpu](https://zipcpu.com/formal/2018/12/28/axilite.html) with formal methods. These bugs are in Xilinx's template implementation of AXI-lite interface, which causes data loss.

#### [xilinx-axi-stream-incomplete-implementation](https://github.com/efeslab/hardware-bugbase/tree/master/xilinx-axi-stream-incomplete-implementation)
This bug is discovered by [zipcpu](https://zipcpu.com/dsp/2020/04/20/axil2axis.html) with formal methods. Like the previous one, it is in Xilinx's template implementation of AXI-stream interface, which causes data loss.

#### [sssp-fsm-error](https://github.com/efeslab/hardware-bugbase/tree/master/sssp-fsm-error)
This bug is a FSM design error in a [single source shortest path](https://github.com/efeslab/optimus-intel-fpga-bbb/tree/master/samples/tutorial/vai_sssp) graph accelerator. This accelerator firstly reads graph vertices from memory, then reads edges. Due to a design error, the circuit may consider the first edge as a vertices.

### Buffer Overflow
#### [reed-solomon-decoder-buffer-overwrite](https://github.com/efeslab/hardware-bugbase/tree/master/reed-solomon-decoder-buffer-overwrite)
This bug is an overflow of a write-combining buffer in the example implementation of [reed solomon decoder](https://github.com/omphardcloud/hardcloud/tree/master/samples/reed_solomon_decoder) of [HardCloud](https://omphardcloud.github.io/). The reed solomon decoder core generate 1 byte at a time, and when 64 bytes are generated, the DMA logic writes it to memory as a cacheline. However, when CCIP tx channel 1 is almfull for a long time, this buffer may be overflow.
* This bug is also a back pressure related one.

#### [sidebuf-overflow-conflict](https://github.com/efeslab/hardware-bugbase/tree/master/sidebuf-overflow-conflict) Bug 2
This bug is a buffer overflow in [Optimus](https://github.com/optimus-hypervisor), an hypervisor for shared-memory FPGAs. In the CCIP interface, when `almfull` is asserted by the FPGA shell, the user logic can only send 8 extra packets. However, in this case, the logic is too complex that the packet generation may not stop within 8 cycles (each cycle may have an extra packet), so we store the extra packets in a "side buffer" (in order to avoid the latency of a fifo). Unfortunately, this buffer is too small that may overflow. 

#### [grayscale-fifo-overflow](https://github.com/efeslab/hardware-bugbase/tree/master/grayscale-fifo-overflow)
This bug is a buffer overflow in an example implementation of [grayscale image processing](https://github.com/omphardcloud/hardcloud/tree/master/samples/grayscale) of [HardCloud](https://omphardcloud.github.io/). When `almfull` is asserted on TxC1 channel (which issues write requests) but not asserted on TxC0 channel (which issues read requests), the circuit will keep reading from the memory, thus overflowing a fifo.

### Integer overflow
#### [dblclockftt-integer-overflow](https://github.com/efeslab/hardware-bugbase/tree/master/dblclockfft-integer-overflow) Bug 2
This bug is originated from https://github.com/ZipCPU/dblclockfft/issues/5. This project is a [generic pipelined FFT core generator](https://github.com/ZipCPU/dblclockfft) designed by [zipcpu](https://zipcpu.com). According to the discussion, it's a integer overflow problem which occurs inside the convround module. Due to the integer overflow, the fft core does not always generate the correct result.



### Interface issues between modules

### Misindexing
#### [fadd-misindexing](https://github.com/efeslab/hardware-bugbase/tree/master/fadd-misindexing)
This bug is a misindexing provided by Brendan West <westbl@umich.edu>. At the buggy place, the correct index is `N-E-1`, and the buggy index is `N-E`.

### Multi-path merge problem

### Dead lock

### Singed/unsigned inconsistency

### Endian problem

### Back pressure
#### [reed-solomon-decoder-buffer-overwrite](https://github.com/efeslab/hardware-bugbase/tree/master/reed-solomon-decoder-buffer-overwrite)
* As described above.

### Signal conflict
#### [sidebuf-overflow-conflict](https://github.com/efeslab/hardware-bugbase/tree/master/sidebuf-overflow-conflict) Bug 1
We talked about the side buffer previously. When `almfull` is deasserted, it's possible that side buffer and user logic both have a packet to send, which may cause a conflict. In this implementation, the packet from user logic is ignored (which is incorrect).

### Performance related
