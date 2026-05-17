###############################################################################
## system_constr.xdc — EBAZ4205 + expansion board
##
## Pin allocation summary (all 18 available DATA pins used):
##   ext_led[3..7]  : G20/J18/G19/H20/J19  (DATA2_5..9)
##   sw[0..7]       : K18/K19/J20/L16/L19/M18/L20/M20  (DATA2_11..19)
##   i2s_mclk       : L17  (DATA2_20)
##   i2s_bclk       : M19  (DATA3_5)
##   i2s_lrclk      : N20  (DATA3_6)
##   i2s_sdata_out  : P18  (DATA3_7)
##   iic_main_scl   : M17  (DATA3_8)
##   iic_main_sda   : L17  ← CONFLICT! see note below
##
## Note: I2C SDA conflicts with I2S MCLK on L17.
##   Resolution: I2S MCLK is optional (PCM5102A has internal PLL).
##   Use L17 for iic_main_sda; MCLK left unconnected or tied low.
##   With 3-wire I2S (no SCK/MCLK), PCM5102A works fine from BCK PLL.
###############################################################################

## ============================================================================
## ENET0 EMIO MII
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
## On-board LEDs (board_led_gpio)
## ============================================================================
set_property -dict {PACKAGE_PIN W13  IOSTANDARD LVCMOS33} [get_ports {board_led[0]}] ;## green
set_property -dict {PACKAGE_PIN W14  IOSTANDARD LVCMOS33} [get_ports {board_led[1]}] ;## red

## ============================================================================
## Extension LEDs (ext_led_gpio, 8-bit)
## [0..2] = existing expansion board LEDs (DATA1)
## [3..7] = new (DATA2_5..9)
## ============================================================================
set_property -dict {PACKAGE_PIN F20  IOSTANDARD LVCMOS33} [get_ports {ext_led[0]}] ;## LED0
set_property -dict {PACKAGE_PIN E19  IOSTANDARD LVCMOS33} [get_ports {ext_led[1]}] ;## LED1
set_property -dict {PACKAGE_PIN F19  IOSTANDARD LVCMOS33} [get_ports {ext_led[2]}] ;## LED2
set_property -dict {PACKAGE_PIN G20  IOSTANDARD LVCMOS33} [get_ports {ext_led[3]}] ;## LED3
set_property -dict {PACKAGE_PIN J18  IOSTANDARD LVCMOS33} [get_ports {ext_led[4]}] ;## LED4
set_property -dict {PACKAGE_PIN G19  IOSTANDARD LVCMOS33} [get_ports {ext_led[5]}] ;## LED5
set_property -dict {PACKAGE_PIN H20  IOSTANDARD LVCMOS33} [get_ports {ext_led[6]}] ;## LED6
set_property -dict {PACKAGE_PIN J19  IOSTANDARD LVCMOS33} [get_ports {ext_led[7]}] ;## LED7

## ============================================================================
## DIP Switches (dipsw_gpio, 8-bit input)
## ============================================================================
set_property -dict {PACKAGE_PIN K18  IOSTANDARD LVCMOS33} [get_ports {sw[0]}] ;## SW0
set_property -dict {PACKAGE_PIN K19  IOSTANDARD LVCMOS33} [get_ports {sw[1]}] ;## SW1
set_property -dict {PACKAGE_PIN J20  IOSTANDARD LVCMOS33} [get_ports {sw[2]}] ;## SW2
set_property -dict {PACKAGE_PIN L16  IOSTANDARD LVCMOS33} [get_ports {sw[3]}] ;## SW3
set_property -dict {PACKAGE_PIN L19  IOSTANDARD LVCMOS33} [get_ports {sw[4]}] ;## SW4
set_property -dict {PACKAGE_PIN M18  IOSTANDARD LVCMOS33} [get_ports {sw[5]}] ;## SW5
set_property -dict {PACKAGE_PIN L20  IOSTANDARD LVCMOS33} [get_ports {sw[6]}] ;## SW6
set_property -dict {PACKAGE_PIN M20  IOSTANDARD LVCMOS33} [get_ports {sw[7]}] ;## SW7

## ============================================================================
## Push Buttons (btn_gpio, 5-bit input)
## ============================================================================
set_property -dict {PACKAGE_PIN A20  IOSTANDARD LVCMOS33} [get_ports {board_btn[0]}] ;## BTN0 BTN_RT
set_property -dict {PACKAGE_PIN H16  IOSTANDARD LVCMOS33} [get_ports {board_btn[1]}] ;## BTN1 BTN_DN
set_property -dict {PACKAGE_PIN B19  IOSTANDARD LVCMOS33} [get_ports {board_btn[2]}] ;## BTN2 BTN_LF
set_property -dict {PACKAGE_PIN B20  IOSTANDARD LVCMOS33} [get_ports {board_btn[3]}] ;## BTN3 BTN_UP
set_property -dict {PACKAGE_PIN C20  IOSTANDARD LVCMOS33} [get_ports {board_btn[4]}] ;## BTN4 BTN_MD

## ============================================================================
## LCD ST7789 SPI + control
## ============================================================================
set_property -dict {PACKAGE_PIN H18  IOSTANDARD LVCMOS33} [get_ports lcd_scl]       ;## LCD_SCL
set_property -dict {PACKAGE_PIN D18  IOSTANDARD LVCMOS33} [get_ports lcd_sda]       ;## LCD_SDA
set_property -dict {PACKAGE_PIN D19  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[0]}]  ;## LCD_DC
set_property -dict {PACKAGE_PIN D20  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[1]}]  ;## LCD_RST
set_property -dict {PACKAGE_PIN H17  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[2]}]  ;## LCD_BL
## LCD ST7789 — all via gpio2 (bitbang SPI) new board
# set_property -dict {PACKAGE_PIN H18  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[4]}]  ;## LCD_SCL
# set_property -dict {PACKAGE_PIN D18  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[5]}]  ;## LCD_SDA
# set_property -dict {PACKAGE_PIN D19  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[0]}]  ;## LCD_DC
# set_property -dict {PACKAGE_PIN D20  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[1]}]  ;## LCD_RST
# set_property -dict {PACKAGE_PIN H17  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[2]}]  ;## LCD_BL
# set_property -dict {PACKAGE_PIN T19  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[3]}]  ;## CS (T19 = spare, board CS接GND可留空)
## LCD ST7789 — all via gpio2 (bitbang SPI) old board
## lcd_ctl[0]=DC   lcd_ctl[1]=RST  lcd_ctl[2]=BL  lcd_ctl[3]=CS   lcd_ctl[4]=SCL  lcd_ctl[5]=SDA
# set_property -dict {PACKAGE_PIN R19  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[4]}]  ;## SCL
# set_property -dict {PACKAGE_PIN P20  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[5]}]  ;## SDA
# set_property -dict {PACKAGE_PIN R18  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[0]}]  ;## DC
# set_property -dict {PACKAGE_PIN N17  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[1]}]  ;## RST
# set_property -dict {PACKAGE_PIN T20  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[2]}]  ;## BL
# set_property -dict {PACKAGE_PIN T19  IOSTANDARD LVCMOS33} [get_ports {lcd_ctl[3]}]  ;## CS (T19 = spare, board CS接GND可留空)


## ============================================================================
## CH340 UART
## ============================================================================
set_property -dict {PACKAGE_PIN N20  IOSTANDARD LVCMOS33} [get_ports uart_rxd] ;## DATA1_6
set_property -dict {PACKAGE_PIN M19  IOSTANDARD LVCMOS33} [get_ports uart_txd] ;## DATA1_11

## ============================================================================
## PWM (J5=V12, J3=U12, via optocoupler)
## ============================================================================
set_property -dict {PACKAGE_PIN V12  IOSTANDARD LVCMOS33} [get_ports {pwm_out[0]}] ;## J5_PWM
set_property -dict {PACKAGE_PIN U12  IOSTANDARD LVCMOS33} [get_ports {pwm_out[1]}] ;## J3_PWM

## ============================================================================
## Timer tachometer inputs (J5=V15, J3=V13, via optocoupler)
## ============================================================================
set_property -dict {PACKAGE_PIN V15  IOSTANDARD LVCMOS33} [get_ports tmr_capture]  ;## J5_SPEED
set_property -dict {PACKAGE_PIN V13  IOSTANDARD LVCMOS33} [get_ports tmr_capture2] ;## J3_SPEED

## ============================================================================
## I2S audio (PCM5102A, 3-wire mode)
## MCLK omitted — PCM5102A generates internally from BCK PLL
## ============================================================================
set_property -dict {PACKAGE_PIN M17  IOSTANDARD LVCMOS33} [get_ports i2s_bclk]      ;## BCK   DATA3_5
set_property -dict {PACKAGE_PIN N17  IOSTANDARD LVCMOS33} [get_ports i2s_lrclk]     ;## LRCK  DATA3_6
# set_property -dict {PACKAGE_PIN D20  IOSTANDARD LVCMOS33} [get_ports i2s_lrclk]     ;## LRCK  DATA3_6
set_property -dict {PACKAGE_PIN P18  IOSTANDARD LVCMOS33} [get_ports i2s_sdata_out] ;## DIN   DATA3_7

## ============================================================================
## I2C main (axi_iic_main, mirrors Zedboard 0x41600000)
## SCL = M17 (DATA3_8), SDA = L17 (DATA2_20)
## ============================================================================
## IIC main — SCL = M17, SDA = L17
## wrapper exposes _i/_o/_t separately; all share one physical IOBUF pin
set_property -dict {PACKAGE_PIN R18  IOSTANDARD LVCMOS33} [get_ports iic_main_scl_io]
set_property -dict {PACKAGE_PIN R19  IOSTANDARD LVCMOS33} [get_ports iic_main_sda_io]
# set_property -dict {PACKAGE_PIN D19  IOSTANDARD LVCMOS33} [get_ports iic_main_scl_io]
# set_property -dict {PACKAGE_PIN H18  IOSTANDARD LVCMOS33} [get_ports iic_main_sda_io]

## IOB constraints removed — cell paths may differ in this build
