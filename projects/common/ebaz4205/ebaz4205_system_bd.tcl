###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
##
## EBAZ4205 board base system BD.
## Analogous to projects/common/zed/zed_system_bd.tcl, but for EBAZ4205.
##
## Hardware (from system.hwh, embed-me XSA 2020.2):
##   Part:   xc7z010clg400-1
##   CPU:    666.666 MHz, XTAL 33.333 MHz
##   DDR3:   MT41K128M16 HA-15E, 533 MHz, 16-bit, 256 MB
##   UART1:  MIO 24/25, 115200 baud  ← NOTE: NOT 48/49
##   ENET0:  EMIO (RTL8201 via PL pins, NOT direct MIO)
##   SD0:    MIO 40-45, CD on MIO 34
##   NAND:   MIO 0-14 (kept; original boot medium)
##   I2C0:   MIO 26/27
##   GPIO:   MIO + EMIO 64-bit
##   FCLK0:  100 MHz  → sys_cpu_clk
##   FCLK1:  200 MHz  → sys_dma_clk / sys_iodelay_clk
##
## vs. zed_system_bd.tcl:
##   - No PCW_IMPORT_BOARD_PRESET (all params explicit)
##   - No HDMI, I2S, SPDIF, iic_fmc, OTG, SPI EMIO
##   - ENET0 via EMIO → BD ports exposed for system_top.v / XDC
##   - axi_cpu_interconnect NOT created here (ad_cpu_interconnect does it on
##     first call from project-level system_bd.tcl)
###############################################################################

# ---------------------------------------------------------------------------
# Interface / port declarations
# ---------------------------------------------------------------------------

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr
create_bd_intf_port -mode Master \
    -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 fixed_io

# ENET0 EMIO - MII ports (4-bit, matching board RTL8201 PHY)
# BD-internal xlslice/xlconcat handle 8-bit GMII <-> 4-bit MII width adaptation
# MDIO exposed as interface port (wrapper has internal iobuf, mdio_io goes direct to board)
create_bd_port -dir I -from 3 -to 0 ENET0_GMII_RXD_0
create_bd_port -dir I               ENET0_GMII_RX_CLK_0
create_bd_port -dir I               ENET0_GMII_RX_DV_0
create_bd_port -dir I               ENET0_GMII_TX_CLK_0
create_bd_port -dir O -from 3 -to 0 ENET0_GMII_TXD_0
create_bd_port -dir O -from 0 -to 0 ENET0_GMII_TX_EN_0
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 MDIO_ETHERNET_0_0

# GPIO EMIO (64-bit, same convention as zed)
create_bd_port -dir I -from 63 -to 0 gpio_i
create_bd_port -dir O -from 63 -to 0 gpio_o
create_bd_port -dir O -from 63 -to 0 gpio_t

# ---------------------------------------------------------------------------
# PS7 instance
# (ad_ip_instance is from adi_board.tcl — wraps create_bd_cell)
# ---------------------------------------------------------------------------

ad_ip_instance processing_system7 sys_ps7

# Crystal / PLLs
ad_ip_parameter sys_ps7 CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ   {33.333333}
ad_ip_parameter sys_ps7 CONFIG.PCW_ARMPLL_CTRL_FBDIV            {40}
ad_ip_parameter sys_ps7 CONFIG.PCW_IOPLL_CTRL_FBDIV             {36}
ad_ip_parameter sys_ps7 CONFIG.PCW_DDRPLL_CTRL_FBDIV            {32}
ad_ip_parameter sys_ps7 CONFIG.PCW_APU_PERIPHERAL_FREQMHZ       {666.666666}
ad_ip_parameter sys_ps7 CONFIG.PCW_CPU_CPU_PLL_FREQMHZ          {1333.333}
ad_ip_parameter sys_ps7 CONFIG.PCW_CPU_PERIPHERAL_CLKSRC        {ARM PLL}
ad_ip_parameter sys_ps7 CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0      {2}

# DDR3
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_PARTNO           {MT41K128M16 HA-15E}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH       {16 Bits}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH        {16 Bit}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE      {DDR 3}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ         {533.333333}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY  {2048 MBits}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT   {14}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT   {10}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT  {3}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_SPEED_BIN        {DDR3_1066F}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_CL               {7}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_CWL              {6}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_BL               {8}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_T_RCD            {7}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_T_RP             {7}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_T_RC             {49.5}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN        {36.0}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_T_FAW            {45.0}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE   {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE  {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_PACKAGE_NAME                 {clg400}
ad_ip_parameter sys_ps7 CONFIG.PCW_PRESET_BANK0_VOLTAGE         {LVCMOS 3.3V}
ad_ip_parameter sys_ps7 CONFIG.PCW_PRESET_BANK1_VOLTAGE         {LVCMOS 3.3V}

# UART1 (MIO 24/25 — NOT 48/49)
ad_ip_parameter sys_ps7 CONFIG.PCW_UART1_PERIPHERAL_ENABLE      {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_UART1_UART1_IO               {MIO 24 .. 25}
ad_ip_parameter sys_ps7 CONFIG.PCW_UART1_BAUD_RATE              {115200}
ad_ip_parameter sys_ps7 CONFIG.PCW_UART0_PERIPHERAL_ENABLE      {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_UART_PERIPHERAL_CLKSRC       {IO PLL}
ad_ip_parameter sys_ps7 CONFIG.PCW_UART_PERIPHERAL_DIVISOR0     {12}

# Ethernet EMIO
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_PERIPHERAL_ENABLE      {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_ENET0_IO               {EMIO}
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_GRP_MDIO_ENABLE        {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_GRP_MDIO_IO            {EMIO}
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC      {External}
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ     {100 Mbps}
ad_ip_parameter sys_ps7 CONFIG.PCW_ENET1_PERIPHERAL_ENABLE      {0}

# SD0
ad_ip_parameter sys_ps7 CONFIG.PCW_SD0_PERIPHERAL_ENABLE        {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_SD0_SD0_IO                   {MIO 40 .. 45}
ad_ip_parameter sys_ps7 CONFIG.PCW_SD0_GRP_CD_ENABLE            {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_SD0_GRP_CD_IO                {MIO 34}
ad_ip_parameter sys_ps7 CONFIG.PCW_SD0_GRP_WP_ENABLE            {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_SD0_GRP_POW_ENABLE           {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_SD1_PERIPHERAL_ENABLE        {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC       {IO PLL}
ad_ip_parameter sys_ps7 CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0     {60}
ad_ip_parameter sys_ps7 CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ      {20}

# NAND (MIO 0-14, original boot medium — keep enabled)
ad_ip_parameter sys_ps7 CONFIG.PCW_NAND_PERIPHERAL_ENABLE       {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_NAND_NAND_IO                 {MIO 0 2.. 14}
ad_ip_parameter sys_ps7 CONFIG.PCW_SMC_PERIPHERAL_CLKSRC        {IO PLL}
ad_ip_parameter sys_ps7 CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0      {12}

# I2C0
ad_ip_parameter sys_ps7 CONFIG.PCW_I2C0_PERIPHERAL_ENABLE       {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_I2C0_I2C0_IO                 {MIO 26 .. 27}

# GPIO (MIO + EMIO 64-bit)
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_MIO_GPIO_ENABLE         {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_MIO_GPIO_IO             {MIO}
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE        {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_EMIO_GPIO_IO            {64}

# PL Clocks
# FCLK0 = 100 MHz: IO PLL (600 MHz) / 3 / 2 = 100 MHz
# FCLK1 = 200 MHz: IO PLL (600 MHz) / 3 / 1 = 200 MHz
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC     {IO PLL}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0   {3}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1   {2}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK_CLK0_BUF               {TRUE}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC     {IO PLL}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0   {3}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1   {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_FCLK_CLK1_BUF               {TRUE}
ad_ip_parameter sys_ps7 CONFIG.PCW_EN_CLK1_PORT                {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_EN_RST1_PORT                {1}

# AXI fabric
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_M_AXI_GP0               {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_FABRIC_INTERRUPT         {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_IRQ_F2P_INTR                {1}
ad_ip_parameter sys_ps7 CONFIG.PCW_IRQ_F2P_MODE                REVERSE

# Disabled peripherals
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI0_PERIPHERAL_ENABLE      {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI1_PERIPHERAL_ENABLE      {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_USB0_PERIPHERAL_ENABLE      {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_TTC0_PERIPHERAL_ENABLE      {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_TTC1_PERIPHERAL_ENABLE      {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_WDT_PERIPHERAL_ENABLE       {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA0                    {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA1                    {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA2                    {0}
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA3                    {0}

# ---------------------------------------------------------------------------
# Interrupt concatenation (16 ports, same as zed)
# ---------------------------------------------------------------------------

ad_ip_instance xlconcat sys_concat_intc
ad_ip_parameter sys_concat_intc CONFIG.NUM_PORTS 16

# ---------------------------------------------------------------------------
# Reset + clock infrastructure (mirrors zed_system_bd.tcl exactly)
# ---------------------------------------------------------------------------

ad_ip_instance proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance proc_sys_reset sys_200m_rstgen
ad_ip_parameter sys_200m_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect  sys_cpu_clk          sys_ps7/FCLK_CLK0
ad_connect  sys_200m_clk         sys_ps7/FCLK_CLK1

ad_connect  sys_cpu_reset        sys_rstgen/peripheral_reset
ad_connect  sys_cpu_resetn       sys_rstgen/peripheral_aresetn
ad_connect  sys_cpu_clk          sys_rstgen/slowest_sync_clk
ad_connect  sys_rstgen/ext_reset_in   sys_ps7/FCLK_RESET0_N

ad_connect  sys_200m_reset       sys_200m_rstgen/peripheral_reset
ad_connect  sys_200m_resetn      sys_200m_rstgen/peripheral_aresetn
ad_connect  sys_200m_clk         sys_200m_rstgen/slowest_sync_clk
ad_connect  sys_200m_rstgen/ext_reset_in  sys_ps7/FCLK_RESET1_N

# Global net pointers (consumed by ad_cpu_interconnect etc.)
set sys_cpu_clk        [get_bd_nets sys_cpu_clk]
set sys_dma_clk        [get_bd_nets sys_200m_clk]
set sys_iodelay_clk    [get_bd_nets sys_200m_clk]

set sys_cpu_reset      [get_bd_nets sys_cpu_reset]
set sys_cpu_resetn     [get_bd_nets sys_cpu_resetn]
set sys_dma_reset      [get_bd_nets sys_200m_reset]
set sys_dma_resetn     [get_bd_nets sys_200m_resetn]
set sys_iodelay_reset  [get_bd_nets sys_200m_reset]
set sys_iodelay_resetn [get_bd_nets sys_200m_resetn]

# ---------------------------------------------------------------------------
# PS7 port connections
# ---------------------------------------------------------------------------

ad_connect  ddr       sys_ps7/DDR
ad_connect  fixed_io  sys_ps7/FIXED_IO

# GPIO EMIO
ad_connect  gpio_i    sys_ps7/GPIO_I
ad_connect  gpio_o    sys_ps7/GPIO_O
ad_connect  gpio_t    sys_ps7/GPIO_T

# Interrupt controller
ad_connect  sys_concat_intc/dout  sys_ps7/IRQ_F2P
ad_connect  sys_concat_intc/In15  GND
ad_connect  sys_concat_intc/In14  GND
ad_connect  sys_concat_intc/In13  GND
ad_connect  sys_concat_intc/In12  GND
ad_connect  sys_concat_intc/In11  GND
ad_connect  sys_concat_intc/In10  GND
ad_connect  sys_concat_intc/In9   GND
ad_connect  sys_concat_intc/In8   GND
ad_connect  sys_concat_intc/In7   GND
ad_connect  sys_concat_intc/In6   GND
ad_connect  sys_concat_intc/In5   GND
ad_connect  sys_concat_intc/In4   GND
ad_connect  sys_concat_intc/In3   GND
ad_connect  sys_concat_intc/In2   GND
ad_connect  sys_concat_intc/In1   GND
ad_connect  sys_concat_intc/In0   GND

# ENET0 EMIO - BD-level 8bit<->4bit adaptation (from blkf2016 reference)
# xlslice: cut GMII TXD[7:0] down to MII TXD[3:0]
ad_ip_instance xlslice eth_txd_slice
ad_ip_parameter eth_txd_slice CONFIG.DIN_WIDTH  {8}
ad_ip_parameter eth_txd_slice CONFIG.DIN_FROM   {3}
ad_ip_parameter eth_txd_slice CONFIG.DIN_TO     {0}
ad_ip_parameter eth_txd_slice CONFIG.DOUT_WIDTH {4}

# xlconcat: pad RXD[3:0] with 4 zeros -> GMII RXD[7:0]
ad_ip_instance xlconcat eth_rxd_concat
ad_ip_parameter eth_rxd_concat CONFIG.NUM_PORTS {2}
ad_ip_parameter eth_rxd_concat CONFIG.IN0_WIDTH {4}
ad_ip_parameter eth_rxd_concat CONFIG.IN1_WIDTH {4}

ad_ip_instance xlconstant eth_rxd_pad
ad_ip_parameter eth_rxd_pad CONFIG.CONST_VAL   {0}
ad_ip_parameter eth_rxd_pad CONFIG.CONST_WIDTH {4}

# MDIO interface port connection
connect_bd_intf_net [get_bd_intf_pins sys_ps7/MDIO_ETHERNET_0] [get_bd_intf_ports MDIO_ETHERNET_0_0]

# RX: board 4-bit -> concat 8-bit -> PS7
ad_connect ENET0_GMII_RXD_0      eth_rxd_concat/In0
ad_connect eth_rxd_pad/dout      eth_rxd_concat/In1
ad_connect eth_rxd_concat/dout   sys_ps7/ENET0_GMII_RXD
ad_connect ENET0_GMII_RX_CLK_0  sys_ps7/ENET0_GMII_RX_CLK
ad_connect ENET0_GMII_RX_DV_0   sys_ps7/ENET0_GMII_RX_DV

# TX: PS7 -> GMII 8-bit -> slice 4-bit -> board
ad_connect sys_ps7/ENET0_GMII_TXD    eth_txd_slice/Din
ad_connect eth_txd_slice/Dout        ENET0_GMII_TXD_0
ad_connect sys_ps7/ENET0_GMII_TX_EN  ENET0_GMII_TX_EN_0
ad_connect ENET0_GMII_TX_CLK_0      sys_ps7/ENET0_GMII_TX_CLK

# ---------------------------------------------------------------------------
# System ID (same pattern as zed_system_bd.tcl)
# ---------------------------------------------------------------------------

ad_ip_instance axi_sysid axi_sysid_0
ad_ip_instance sysid_rom rom_sys_0

ad_connect  axi_sysid_0/rom_addr      rom_sys_0/rom_addr
ad_connect  axi_sysid_0/sys_rom_data  rom_sys_0/rom_data
ad_connect  sys_cpu_clk               rom_sys_0/clk

ad_cpu_interconnect 0x45000000 axi_sysid_0

