# system_constr.xdc - EBAZ4205
# Pin assignments verified from blkf2016/ebaz4205.xdc (hardware-tested reference)
# MIO peripherals (UART1, SD0, NAND, I2C0) need no XDC -- handled by PS7 MIO config

# ENET0 EMIO MII -- RTL8201 PHY
# RX
set_property PACKAGE_PIN U14  [get_ports ENET0_GMII_RX_CLK_0]
set_property PACKAGE_PIN W16  [get_ports ENET0_GMII_RX_DV_0]
set_property PACKAGE_PIN Y16  [get_ports {ENET0_GMII_RXD_0[0]}]
set_property PACKAGE_PIN V16  [get_ports {ENET0_GMII_RXD_0[1]}]
set_property PACKAGE_PIN V17  [get_ports {ENET0_GMII_RXD_0[2]}]
set_property PACKAGE_PIN Y17  [get_ports {ENET0_GMII_RXD_0[3]}]

# TX
set_property PACKAGE_PIN U15  [get_ports ENET0_GMII_TX_CLK_0]
set_property PACKAGE_PIN W19  [get_ports {ENET0_GMII_TX_EN_0[0]}]
set_property PACKAGE_PIN W18  [get_ports {ENET0_GMII_TXD_0[0]}]
set_property PACKAGE_PIN Y18  [get_ports {ENET0_GMII_TXD_0[1]}]
set_property PACKAGE_PIN V18  [get_ports {ENET0_GMII_TXD_0[2]}]
set_property PACKAGE_PIN Y19  [get_ports {ENET0_GMII_TXD_0[3]}]

# MDIO
set_property PACKAGE_PIN W15  [get_ports MDIO_ETHERNET_0_0_mdc]
set_property PACKAGE_PIN Y14  [get_ports MDIO_ETHERNET_0_0_mdio_io]

# All ETH pins are in bank 34 (VCCO = 3.3V)
set_property IOSTANDARD LVCMOS33 [get_ports ENET0_GMII_*]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO_ETHERNET_0_0_*]

# RX clock timing constraint
create_clock -name eth_rx_clk -period 40.000 [get_ports ENET0_GMII_RX_CLK_0]
