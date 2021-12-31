create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_NUM_OF_PROBES {2} CONFIG.C_DATA_DEPTH {8192} CONFIG.C_PROBE0_WIDTH {71} CONFIG.C_PROBE0_MU_CNT {2} CONFIG.C_PROBE0_TYPE {1} CONFIG.C_PROBE1_WIDTH {1} CONFIG.C_PROBE1_MU_CNT {2} CONFIG.C_PROBE1_TYPE {2}] [get_ips ila_0]
# total width: 71
