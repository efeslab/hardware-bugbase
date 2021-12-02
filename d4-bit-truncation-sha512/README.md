# D4 - Bit Truncation - SHA512

Code: https://github.com/efeslab/hardcloud/tree/e28ca96fdbb67904ef909fb04e026cf6dc724198/samples/sha512

This bug occurs in the memory requestor of an SHA512 accelerator. CPU-side software configure the accelerator with the location of the data to be hashed by writing the address to the accelerator. Because the accelerator can only access memory at cacheline granularity, it needs to translate a normal memory address to a cacheline address by erasing both the least significant bits (because they must be 0) and the most significant bits (because they are not supported by the memory bus).

Unfortunately, the accelerator performs a width conversion before doing the shift; as a result, some meaningful bits (i.e., bit 42-47) are erased.

This bug would cause the accelerator to access an invalid address, thus triggering an IOMMU page fault which freezes the whole accelerator.

### Synthetic Code
``` verilog
logic [41:0] left;
logic [63:0] right;
assign left = 42'(right) >> 6;
```

To fix the bug, simply change the third line to:

```verilog
assign left = 42'(right >> 6);
```



