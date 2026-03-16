###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project imageon_ebaz4205

adi_project_files imageon_ebaz4205 [list \
  "system_top.v" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "system_constr.xdc"]

adi_project_run imageon_ebaz4205
