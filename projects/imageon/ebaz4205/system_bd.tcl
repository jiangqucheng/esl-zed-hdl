###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
##
## imageon/ebaz4205/system_bd.tcl — minimum system (Linux boot only).
## Sources ebaz4205_system_bd.tcl which includes PS7, clocks, resets,
## ETH EMIO, GPIO, and axi_sysid.
## Add EECE4534 peripherals here later (same pattern as imageon/zed/system_bd.tcl).
###############################################################################

source $ad_hdl_dir/projects/common/ebaz4205/ebaz4205_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

# system ID — set parameters and generate init file
# (axi_sysid_0 and rom_sys_0 are instantiated in ebaz4205_system_bd.tcl)
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0   CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0   CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file
