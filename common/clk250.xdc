# For axi-lite sdspi-path-merge sdspi-deadlock sdspi-endian fft fadd
create_clock -period 4.000 -name S_AXI_ACLK -waveform {0.000 2.000} [get_nets S_AXI_ACLK]
# For axi-stream
create_clock -period 4.000 -name M_AXIS_ACLK -waveform {0.000 2.000} [get_nets M_AXIS_ACLK]
