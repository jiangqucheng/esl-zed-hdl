###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
##
## Zedboard standalone (no FMC-IMAGEON).
## HDMI TX via onboard ADV7511 (16-bit parallel).
## All FMC-imageon constraints removed.
## EECE4534 board peripheral constraints included.
###############################################################################

# HDMI TX - onboard ADV7511 (16-bit parallel interface)
# These pins are on the zedboard PCB connecting directly to ADV7511.

set_property  -dict {PACKAGE_PIN  W18   IOSTANDARD LVCMOS33}           [get_ports hdmi_out_clk]
set_property  -dict {PACKAGE_PIN  W17   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_vsync]
set_property  -dict {PACKAGE_PIN  V17   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_hsync]
set_property  -dict {PACKAGE_PIN  U16   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data_e]
set_property  -dict {PACKAGE_PIN  Y13   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[0]]
set_property  -dict {PACKAGE_PIN  AA13  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[1]]
set_property  -dict {PACKAGE_PIN  AA14  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[2]]
set_property  -dict {PACKAGE_PIN  Y14   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[3]]
set_property  -dict {PACKAGE_PIN  AB15  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[4]]
set_property  -dict {PACKAGE_PIN  AB16  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[5]]
set_property  -dict {PACKAGE_PIN  AA16  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[6]]
set_property  -dict {PACKAGE_PIN  AB17  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[7]]
set_property  -dict {PACKAGE_PIN  AA17  IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[8]]
set_property  -dict {PACKAGE_PIN  Y15   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[9]]
set_property  -dict {PACKAGE_PIN  W13   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[10]]
set_property  -dict {PACKAGE_PIN  W15   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[11]]
set_property  -dict {PACKAGE_PIN  V15   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[12]]
set_property  -dict {PACKAGE_PIN  U17   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[13]]
set_property  -dict {PACKAGE_PIN  V14   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[14]]
set_property  -dict {PACKAGE_PIN  V13   IOSTANDARD LVCMOS33  IOB TRUE} [get_ports hdmi_data[15]]

# SPDIF TX (onboard)

set_property  -dict {PACKAGE_PIN  U15   IOSTANDARD LVCMOS33} [get_ports spdif]

# I2S audio (onboard codec)

set_property  -dict {PACKAGE_PIN  AB2   IOSTANDARD LVCMOS33} [get_ports i2s_mclk]
set_property  -dict {PACKAGE_PIN  AA6   IOSTANDARD LVCMOS33} [get_ports i2s_bclk]
set_property  -dict {PACKAGE_PIN  Y6    IOSTANDARD LVCMOS33} [get_ports i2s_lrclk]
set_property  -dict {PACKAGE_PIN  Y8    IOSTANDARD LVCMOS33} [get_ports i2s_sdata_out]
set_property  -dict {PACKAGE_PIN  AA7   IOSTANDARD LVCMOS33} [get_ports i2s_sdata_in]

# IIC onboard

set_property  -dict {PACKAGE_PIN  R7    IOSTANDARD LVCMOS33} [get_ports iic_scl]
set_property  -dict {PACKAGE_PIN  U7    IOSTANDARD LVCMOS33} [get_ports iic_sda]
set_property  -dict {PACKAGE_PIN  AA18  IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_mux_scl[1]]
set_property  -dict {PACKAGE_PIN  Y16   IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_mux_sda[1]]
set_property  -dict {PACKAGE_PIN  AB4   IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_mux_scl[0]]
set_property  -dict {PACKAGE_PIN  AB5   IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_mux_sda[0]]

# External IIC

set_property  -dict {PACKAGE_PIN  U4    IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_ext_scl]
set_property  -dict {PACKAGE_PIN  T4    IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_ext_sda]

# OTG

set_property  -dict {PACKAGE_PIN  L16   IOSTANDARD LVCMOS25} [get_ports otg_vbusoc]

# Board buttons

set_property  -dict {PACKAGE_PIN  P16   IOSTANDARD LVCMOS25} [get_ports board_btn[0]]   ; ## BTNC
set_property  -dict {PACKAGE_PIN  R16   IOSTANDARD LVCMOS25} [get_ports board_btn[1]]   ; ## BTND
set_property  -dict {PACKAGE_PIN  N15   IOSTANDARD LVCMOS25} [get_ports board_btn[2]]   ; ## BTNL
set_property  -dict {PACKAGE_PIN  R18   IOSTANDARD LVCMOS25} [get_ports board_btn[3]]   ; ## BTNR
set_property  -dict {PACKAGE_PIN  T18   IOSTANDARD LVCMOS25} [get_ports board_btn[4]]   ; ## BTNU

# OLED (SPI data/clk from oled_spi IP; control signals from led_gpio/gpio2)

set_property  -dict {PACKAGE_PIN  U10   IOSTANDARD LVCMOS33} [get_ports oled_ctl[0]]   ; ## OLED-DC
set_property  -dict {PACKAGE_PIN  U9    IOSTANDARD LVCMOS33} [get_ports oled_ctl[1]]   ; ## OLED-RES
set_property  -dict {PACKAGE_PIN  U11   IOSTANDARD LVCMOS33} [get_ports oled_ctl[2]]   ; ## OLED-VBAT
set_property  -dict {PACKAGE_PIN  U12   IOSTANDARD LVCMOS33} [get_ports oled_ctl[3]]   ; ## OLED-VDD
set_property  -dict {PACKAGE_PIN  AB12  IOSTANDARD LVCMOS33} [get_ports oled_sck]      ; ## OLED-SCLK
set_property  -dict {PACKAGE_PIN  AA12  IOSTANDARD LVCMOS33} [get_ports oled_data]     ; ## OLED-SDIN

# Board switches

set_property  -dict {PACKAGE_PIN  F22   IOSTANDARD LVCMOS25} [get_ports board_sw[0]]   ; ## SW0
set_property  -dict {PACKAGE_PIN  G22   IOSTANDARD LVCMOS25} [get_ports board_sw[1]]   ; ## SW1
set_property  -dict {PACKAGE_PIN  H22   IOSTANDARD LVCMOS25} [get_ports board_sw[2]]   ; ## SW2
set_property  -dict {PACKAGE_PIN  F21   IOSTANDARD LVCMOS25} [get_ports board_sw[3]]   ; ## SW3
set_property  -dict {PACKAGE_PIN  H19   IOSTANDARD LVCMOS25} [get_ports board_sw[4]]   ; ## SW4
set_property  -dict {PACKAGE_PIN  H18   IOSTANDARD LVCMOS25} [get_ports board_sw[5]]   ; ## SW5
set_property  -dict {PACKAGE_PIN  H17   IOSTANDARD LVCMOS25} [get_ports board_sw[6]]   ; ## SW6
set_property  -dict {PACKAGE_PIN  M15   IOSTANDARD LVCMOS25} [get_ports board_sw[7]]   ; ## SW7

# Board LEDs

set_property  -dict {PACKAGE_PIN  T22   IOSTANDARD LVCMOS33} [get_ports board_leds[0]] ; ## LD0
set_property  -dict {PACKAGE_PIN  T21   IOSTANDARD LVCMOS33} [get_ports board_leds[1]] ; ## LD1
set_property  -dict {PACKAGE_PIN  U22   IOSTANDARD LVCMOS33} [get_ports board_leds[2]] ; ## LD2
set_property  -dict {PACKAGE_PIN  U21   IOSTANDARD LVCMOS33} [get_ports board_leds[3]] ; ## LD3
set_property  -dict {PACKAGE_PIN  V22   IOSTANDARD LVCMOS33} [get_ports board_leds[4]] ; ## LD4
set_property  -dict {PACKAGE_PIN  W22   IOSTANDARD LVCMOS33} [get_ports board_leds[5]] ; ## LD5
set_property  -dict {PACKAGE_PIN  U19   IOSTANDARD LVCMOS33} [get_ports board_leds[6]] ; ## LD6
set_property  -dict {PACKAGE_PIN  U14   IOSTANDARD LVCMOS33} [get_ports board_leds[7]] ; ## LD7

# PMOD JB (pmod_gpio[7:0])

set_property  -dict {PACKAGE_PIN  W12   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[0]]  ; ## JB1
set_property  -dict {PACKAGE_PIN  W11   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[1]]  ; ## JB2
set_property  -dict {PACKAGE_PIN  V10   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[2]]  ; ## JB3
set_property  -dict {PACKAGE_PIN  W8    IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[3]]  ; ## JB4
set_property  -dict {PACKAGE_PIN  V12   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[4]]  ; ## JB7
set_property  -dict {PACKAGE_PIN  W10   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[5]]  ; ## JB8
set_property  -dict {PACKAGE_PIN  V9    IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[6]]  ; ## JB9
set_property  -dict {PACKAGE_PIN  V8    IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[7]]  ; ## JB10

# PMOD JA (pmod_gpio[15:8])

set_property  -dict {PACKAGE_PIN  Y11   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[8]]  ; ## JA1
set_property  -dict {PACKAGE_PIN  AA11  IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[9]]  ; ## JA2
set_property  -dict {PACKAGE_PIN  Y10   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[10]] ; ## JA3
set_property  -dict {PACKAGE_PIN  AA9   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[11]] ; ## JA4
set_property  -dict {PACKAGE_PIN  AB11  IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[12]] ; ## JA7
set_property  -dict {PACKAGE_PIN  AB10  IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[13]] ; ## JA8
set_property  -dict {PACKAGE_PIN  AB9   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[14]] ; ## JA9
set_property  -dict {PACKAGE_PIN  AA8   IOSTANDARD LVCMOS33} [get_ports pmod_gpio_buf[15]] ; ## JA10

# GPIO (gpio_bd - XADC-GIO and OTG-RESETN only; lower bits unused here)

set_property  -dict {PACKAGE_PIN  H15   IOSTANDARD LVCMOS25} [get_ports gpio_bd[27]]   ; ## XADC-GIO0
set_property  -dict {PACKAGE_PIN  R15   IOSTANDARD LVCMOS25} [get_ports gpio_bd[28]]   ; ## XADC-GIO1
set_property  -dict {PACKAGE_PIN  K15   IOSTANDARD LVCMOS25} [get_ports gpio_bd[29]]   ; ## XADC-GIO2
set_property  -dict {PACKAGE_PIN  J15   IOSTANDARD LVCMOS25} [get_ports gpio_bd[30]]   ; ## XADC-GIO3
set_property  -dict {PACKAGE_PIN  G17   IOSTANDARD LVCMOS25} [get_ports gpio_bd[31]]   ; ## OTG-RESETN

# PWM outputs

set_property  -dict {PACKAGE_PIN  AB7   IOSTANDARD LVCMOS33} [get_ports pwm_out[0]]
set_property  -dict {PACKAGE_PIN  AB6   IOSTANDARD LVCMOS33} [get_ports pwm_out[1]]

# Timer capture / generate

set_property  -dict {PACKAGE_PIN  Y4    IOSTANDARD LVCMOS33} [get_ports tmr_capture]
set_property  -dict {PACKAGE_PIN  AA4   IOSTANDARD LVCMOS33} [get_ports tmr_generate]

# UART

set_property  -dict {PACKAGE_PIN  T6    IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property  -dict {PACKAGE_PIN  R6    IOSTANDARD LVCMOS33} [get_ports uart_rx]
