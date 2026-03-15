###############################################################################
## system_constr.xdc — EBAZ4205 + expansion board
## All pins verified against official EBAZ4205.xdc + expansion board mapping
###############################################################################

## ============================================================================
## ENET0 EMIO MII — RTL8201 PHY (verified from blkf2016)
## ============================================================================
set_property PACKAGE_PIN U14  [get_ports ENET0_GMII_RX_CLK_0]
set_property PACKAGE_PIN W16  [get_ports ENET0_GMII_RX_DV_0]
set_property PACKAGE_PIN Y16  [get_ports {ENET0_GMII_RXD_0[0]}]
set_property PACKAGE_PIN V16  [get_ports {ENET0_GMII_RXD_0[1]}]
set_property PACKAGE_PIN V17  [get_ports {ENET0_GMII_RXD_0[2]}]
set_property PACKAGE_PIN Y17  [get_ports {ENET0_GMII_RXD_0[3]}]
set_property PACKAGE_PIN U15  [get_ports ENET0_GMII_TX_CLK_0]
set_property PACKAGE_PIN W19  [get_ports {ENET0_GMII_TX_EN_0[0]}]
set_property PACKAGE_PIN W18  [get_ports {ENET0_GMII_TXD_0[0]}]
set_property PACKAGE_PIN Y18  [get_ports {ENET0_GMII_TXD_0[1]}]
set_property PACKAGE_PIN V18  [get_ports {ENET0_GMII_TXD_0[2]}]
set_property PACKAGE_PIN Y19  [get_ports {ENET0_GMII_TXD_0[3]}]
set_property PACKAGE_PIN W15  [get_ports MDIO_ETHERNET_0_0_mdc]
set_property PACKAGE_PIN Y14  [get_ports MDIO_ETHERNET_0_0_mdio_io]
set_property IOSTANDARD LVCMOS33 [get_ports ENET0_GMII_*]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO_ETHERNET_0_0_*]
create_clock -name eth_rx_clk -period 40.000 [get_ports ENET0_GMII_RX_CLK_0]

## ============================================================================
## LEDs — on-board [1:0] + expansion [4:2]
## ============================================================================
set_property -dict {PACKAGE_PIN W13  IOSTANDARD LVCMOS33} [get_ports {board_leds[0]}] ;## green
set_property -dict {PACKAGE_PIN W14  IOSTANDARD LVCMOS33} [get_ports {board_leds[1]}] ;## red
set_property -dict {PACKAGE_PIN E19  IOSTANDARD LVCMOS33} [get_ports {board_leds[2]}] ;## LED1(DATA1_18)
set_property -dict {PACKAGE_PIN K17  IOSTANDARD LVCMOS33} [get_ports {board_leds[3]}] ;## LED2(DATA1_20)
set_property -dict {PACKAGE_PIN H18  IOSTANDARD LVCMOS33} [get_ports {board_leds[4]}] ;## LED3(DATA1_15)

## ============================================================================
## Buttons — 5x expansion (DATA3, bank 34)
## ============================================================================
set_property -dict {PACKAGE_PIN T19  IOSTANDARD LVCMOS33} [get_ports {board_btn[0]}] ;## BTN1(DATA3_18)
set_property -dict {PACKAGE_PIN P19  IOSTANDARD LVCMOS33} [get_ports {board_btn[1]}] ;## BTN2(DATA3_15)
set_property -dict {PACKAGE_PIN U20  IOSTANDARD LVCMOS33} [get_ports {board_btn[2]}] ;## BTN3(DATA3_17)
set_property -dict {PACKAGE_PIN U19  IOSTANDARD LVCMOS33} [get_ports {board_btn[3]}] ;## BTN4(DATA3_20)
set_property -dict {PACKAGE_PIN V20  IOSTANDARD LVCMOS33} [get_ports {board_btn[4]}] ;## BTN5(DATA3_19)

## ============================================================================
## LCD ST7789 SPI + control (DATA3, bank 34)
## ============================================================================
set_property -dict {PACKAGE_PIN R19  IOSTANDARD LVCMOS33} [get_ports lcd_scl]        ;## SCL(DATA3_14)
set_property -dict {PACKAGE_PIN P20  IOSTANDARD LVCMOS33} [get_ports lcd_sda]        ;## SDA(DATA3_11)
set_property -dict {PACKAGE_PIN R18  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[0]}]   ;## DC(DATA3_13)
set_property -dict {PACKAGE_PIN N17  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[1]}]   ;## RST(DATA3_9)
set_property -dict {PACKAGE_PIN T20  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[2]}]   ;## BL(DATA3_16)

## ============================================================================
## CH340 UART (DATA1, bank 35)
## ============================================================================
set_property -dict {PACKAGE_PIN H16  IOSTANDARD LVCMOS33} [get_ports uart_rxd]  ;## DATA1_6 → CH340_TXD
set_property -dict {PACKAGE_PIN H17  IOSTANDARD LVCMOS33} [get_ports uart_txd]  ;## DATA1_11 → CH340_RXD

## ============================================================================
## PWM outputs — J5/J3 fan connectors (on EBAZ board, bank 34)
## Both via optocoupler: FPGA drives, fan speed controlled
## ============================================================================
set_property -dict {PACKAGE_PIN V12  IOSTANDARD LVCMOS33} [get_ports {pwm_out[0]}]  ;## J5_PWM
set_property -dict {PACKAGE_PIN U12  IOSTANDARD LVCMOS33} [get_ports {pwm_out[1]}]  ;## J3_PWM

## ============================================================================
## Timer tachometer inputs — J5/J3 fan SPEED signals (on EBAZ board, bank 34)
## Fan tach pulses, via optocoupler: fan speed feedback → FPGA capture
## ============================================================================
set_property -dict {PACKAGE_PIN V15  IOSTANDARD LVCMOS33} [get_ports tmr_capture]   ;## J5_SPEED
set_property -dict {PACKAGE_PIN V13  IOSTANDARD LVCMOS33} [get_ports tmr_capture2]  ;## J3_SPEED

## ============================================================================
## Timer generate output (DATA2_8, bank 35)
## ============================================================================
set_property -dict {PACKAGE_PIN H20  IOSTANDARD LVCMOS33} [get_ports tmr_generate]  ;## DATA2_8

## ============================================================================
## PMOD GPIO [15:0] — DATA2 (14 pins) + DATA3 spare (2 pins)
##
## [0..13] = DATA2: G20/J18/G19/H20 already used by timer, remaining 10:
##   wait — H20=tmr_generate, G20=free, J18=free, G19=free
##   DATA2 free: G20(5) J18(6) G19(7) J19(9) K18(11) K19(13)
##               J20(14) L16(15) L19(16) M18(17) L20(18) M20(19) L17(20)
##   Use 14: G20 J18 G19 J19 K18 K19 J20 L16 L19 M18 L20 M20 L17 + DATA3_M19
## [14..15] = DATA3 spare: M19 N20
## ============================================================================
set_property -dict {PACKAGE_PIN G20  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[0]}]  ;## DATA2_5
set_property -dict {PACKAGE_PIN J18  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[1]}]  ;## DATA2_6
set_property -dict {PACKAGE_PIN G19  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[2]}]  ;## DATA2_7
set_property -dict {PACKAGE_PIN J19  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[3]}]  ;## DATA2_9
set_property -dict {PACKAGE_PIN K18  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[4]}]  ;## DATA2_11
set_property -dict {PACKAGE_PIN K19  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[5]}]  ;## DATA2_13
set_property -dict {PACKAGE_PIN J20  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[6]}]  ;## DATA2_14
set_property -dict {PACKAGE_PIN L16  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[7]}]  ;## DATA2_15
set_property -dict {PACKAGE_PIN L19  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[8]}]  ;## DATA2_16
set_property -dict {PACKAGE_PIN M18  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[9]}]  ;## DATA2_17
set_property -dict {PACKAGE_PIN L20  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[10]}] ;## DATA2_18
set_property -dict {PACKAGE_PIN M20  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[11]}] ;## DATA2_19
set_property -dict {PACKAGE_PIN L17  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[12]}] ;## DATA2_20
set_property -dict {PACKAGE_PIN M19  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[13]}] ;## DATA3_5
set_property -dict {PACKAGE_PIN N20  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[14]}] ;## DATA3_6
set_property -dict {PACKAGE_PIN P18  IOSTANDARD LVCMOS33} [get_ports {pmod_gpio_buf[15]}] ;## DATA3_7

## ============================================================================
## IOB constraints for LCD SPI
## ============================================================================
set_property IOB FALSE [get_cells {i_system_wrapper/system_i/lcd_spi/U0/NO_DUAL_QUAD_MODE.QSPI_NORMAL/IO0_I_REG}]
set_property IOB FALSE [get_cells {i_system_wrapper/system_i/lcd_spi/U0/NO_DUAL_QUAD_MODE.QSPI_NORMAL/IO1_I_REG}]
