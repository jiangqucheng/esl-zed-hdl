###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
##
## imageon/ebaz4205/system_bd.tcl
##
## Board resources:
##   On-board:  LED×2 (W13/W14), UART1 console (MIO24/25), ETH (EMIO)
##   Expansion: LED×3, Button×5, CH340 UART, LCD SPI, Buzzer, Timers, PMOD
##
## Peripheral map (mirrors imageon/zed/system_bd.tcl where possible):
##   0x411F0000  pmod_gpio    (16-bit bidir)
##   0x41200000  led_gpio     (gpio1=5-bit LED out, gpio2=5-bit lcd_ctl out)
##   0x41210000  dipsw_gpio   (8-bit in, no physical pins — reads 0)
##   0x41220000  btn_gpio     (5-bit in, expansion buttons)
##   0x41230000  lcd_spi      (SPI to LCD ST7789, replaces oled_spi)
##   0x41240000  tmr0         (dual timer + PWM0)
##   0x41250000  tmr1         (dual timer + PWM1)
##   0x41260000  mux0         (1-bit 2-input mux, ties tmr0/led to tmr3 capture)
##   0x41270000  mux1         (1-bit 2-input mux)
##   0x41280000  tmr2         (capture timer)
##   0x41290000  tmr3         (capture timer)
##   0x412A0000  pluart0      (UART Lite → CH340, 115200 baud)
##   0x41640000  axi_iic_ext  (spare I2C, no physical pins)
##   0x41650000  xadc0        (on-chip temperature/voltage)
##   0x45000000  axi_sysid_0
###############################################################################

source $ad_hdl_dir/projects/common/ebaz4205/ebaz4205_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

# system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0   CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0   CONFIG.ROM_ADDR_BITS 9
sysid_gen_sys_init_file

###############################################################################
## Disconnect interrupt slots we need (all currently GND)
## Slots used: In0=dipsw, In1=btn, In3=lcd_spi, In4=tmr2, In5=tmr3,
##             In6=pmod, In7=pluart0, In8=xadc, In13=iic_ext
###############################################################################

foreach intc_in {In0 In1 In3 In4 In5 In6 In7 In8 In13} {
  disconnect_bd_net \
    [get_bd_nets -of_objects [get_bd_pins sys_concat_intc/$intc_in]] \
    [get_bd_pins sys_concat_intc/$intc_in]
}

###############################################################################
## LED GPIO
## gpio1 [4:0]: 5 LEDs — [0]=board green(W13), [1]=board red(W14),
##                         [2]=ext LED1(E19), [3]=ext LED2(K17), [4]=ext LED3(H18)
## gpio2 [4:0]: 5 LCD control signals — DC, RST, BL, (CS tied GND, SDA via SPI)
###############################################################################

ad_ip_instance axi_gpio led_gpio
ad_ip_parameter led_gpio CONFIG.C_ALL_OUTPUTS   1
ad_ip_parameter led_gpio CONFIG.C_GPIO_WIDTH    5
ad_ip_parameter led_gpio CONFIG.C_IS_DUAL       1
ad_ip_parameter led_gpio CONFIG.C_ALL_OUTPUTS_2 1
ad_ip_parameter led_gpio CONFIG.C_GPIO2_WIDTH   5
ad_cpu_interconnect 0x41200000 led_gpio

create_bd_port -dir O -from 4 -to 0 board_leds
create_bd_port -dir O -from 4 -to 0 lcd_ctl
ad_connect board_leds led_gpio/gpio_io_o
ad_connect lcd_ctl    led_gpio/gpio2_io_o

###############################################################################
## DIP Switch GPIO (no physical switches on board — reads 0)
## Kept for software compatibility with Zedboard image
###############################################################################

ad_ip_instance axi_gpio dipsw_gpio
ad_ip_parameter dipsw_gpio CONFIG.C_ALL_INPUTS        1
ad_ip_parameter dipsw_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter dipsw_gpio CONFIG.C_GPIO_WIDTH        8
ad_cpu_interconnect 0x41210000 dipsw_gpio
ad_connect sys_concat_intc/In0 dipsw_gpio/ip2intc_irpt

# No physical pins — tie input to constant 0
ad_ip_instance xlconstant sw_tie_zero
ad_ip_parameter sw_tie_zero CONFIG.CONST_VAL   {0}
ad_ip_parameter sw_tie_zero CONFIG.CONST_WIDTH {8}
ad_connect sw_tie_zero/dout dipsw_gpio/gpio_io_i

###############################################################################
## Push Button GPIO — 5 buttons on expansion board
###############################################################################

ad_ip_instance axi_gpio btn_gpio
ad_ip_parameter btn_gpio CONFIG.C_ALL_INPUTS        1
ad_ip_parameter btn_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter btn_gpio CONFIG.C_GPIO_WIDTH        5
ad_cpu_interconnect 0x41220000 btn_gpio
ad_connect sys_concat_intc/In1 btn_gpio/ip2intc_irpt

create_bd_port -dir I -from 4 -to 0 board_btn
ad_connect board_btn btn_gpio/gpio_io_i

###############################################################################
## LCD SPI (ST7789, 4-line SPI — same AXI Quad SPI IP as Zedboard OLED)
## SCL → sck_o, SDA → io0_o (MOSI)
###############################################################################

ad_ip_instance axi_quad_spi lcd_spi
ad_ip_parameter lcd_spi CONFIG.C_USE_STARTUP_INT 0
ad_ip_parameter lcd_spi CONFIG.C_USE_STARTUP     0
ad_ip_parameter lcd_spi CONFIG.Multiples16       1
ad_cpu_interconnect 0x41230000 lcd_spi
ad_connect sys_concat_intc/In3 lcd_spi/ip2intc_irpt

create_bd_port -dir O lcd_sda
create_bd_port -dir O lcd_scl
ad_connect lcd_spi/io0_o          lcd_sda
ad_connect lcd_spi/sck_o          lcd_scl
ad_connect GND                    lcd_spi/io1_i
ad_connect sys_ps7/FCLK_CLK0     lcd_spi/ext_spi_clk

###############################################################################
## Timers (identical to Zedboard)
###############################################################################

ad_ip_instance axi_timer tmr0
ad_ip_parameter tmr0 CONFIG.enable_timer2 1
ad_cpu_interconnect 0x41240000 tmr0

ad_ip_instance axi_timer tmr1
ad_ip_parameter tmr1 CONFIG.enable_timer2 1
ad_cpu_interconnect 0x41250000 tmr1

ad_ip_instance axi_timer tmr2
ad_ip_parameter tmr2 CONFIG.enable_timer2  1
ad_ip_parameter tmr2 CONFIG.TRIG1_ASSERT   Active_Low
ad_cpu_interconnect 0x41280000 tmr2
ad_connect sys_concat_intc/In4 tmr2/interrupt

create_bd_port -dir I tmr_capture
create_bd_port -dir I tmr_capture2
create_bd_port -dir O tmr_generate
ad_connect tmr_capture  tmr2/capturetrig0
ad_connect tmr_capture  tmr2/capturetrig1
ad_connect tmr_generate tmr2/generateout0

ad_ip_instance axi_timer tmr3
ad_ip_parameter tmr3 CONFIG.enable_timer2  1
ad_ip_parameter tmr3 CONFIG.TRIG1_ASSERT   Active_Low
ad_cpu_interconnect 0x41290000 tmr3
ad_connect sys_concat_intc/In5 tmr3/interrupt

###############################################################################
## AXI Mux × 2 (identical to Zedboard)
###############################################################################

ad_ip_instance axi_mux mux0
ad_ip_parameter mux0 CONFIG.C_DATA_W  1
ad_ip_parameter mux0 CONFIG.C_INPUT_W 2
ad_cpu_interconnect 0x41260000 mux0
ad_connect tmr0/pwm0         mux0/input_1
ad_connect tmr3/capturetrig0 mux0/dout
ad_connect tmr3/capturetrig1 mux0/dout
ad_connect tmr_capture2 tmr3/capturetrig0

ad_ip_instance axi_mux mux1
ad_ip_parameter mux1 CONFIG.C_DATA_W  1
ad_ip_parameter mux1 CONFIG.C_INPUT_W 2
ad_cpu_interconnect 0x41270000 mux1
ad_connect tmr1/pwm0 mux1/input_1

###############################################################################
## UART Lite → CH340 on expansion board (115200 baud, upgraded from 19200)
###############################################################################

ad_ip_instance axi_uartlite pluart0
ad_ip_parameter pluart0 CONFIG.C_BAUDRATE 115200
ad_cpu_interconnect 0x412A0000 pluart0
ad_connect sys_concat_intc/In7 pluart0/interrupt

create_bd_port -dir I uart_rxd
create_bd_port -dir O uart_txd
ad_connect uart_rxd pluart0/rx
ad_connect uart_txd pluart0/tx

###############################################################################
## PWM output × 2
## pwm_out[0] → tmr0/pwm0 (via mux0) → e.g. Buzzer
## pwm_out[1] → tmr1/pwm0 (via mux1) → e.g. LCD backlight
###############################################################################

# pwm_out[0] -> J5_PWM (V12), pwm_out[1] -> J3_PWM (U12)
# Both go through J3/J5 fan connectors (optocoupler protected)
ad_ip_instance xlconcat pwmconcat
ad_connect tmr0/pwm0 pwmconcat/In0
ad_connect tmr1/pwm0 pwmconcat/In1
create_bd_port -dir O -from 1 -to 0 pwm_out
ad_connect pwm_out pwmconcat/dout

###############################################################################
## LED slice + mux routing (identical to Zedboard)
###############################################################################

ad_ip_instance xlslice ledslice0
ad_ip_parameter ledslice0 CONFIG.DIN_WIDTH  5
ad_ip_parameter ledslice0 CONFIG.DIN_FROM   0
ad_ip_parameter ledslice0 CONFIG.DIN_TO     0

ad_ip_instance xlslice ledslice1
ad_ip_parameter ledslice1 CONFIG.DIN_WIDTH  5
ad_ip_parameter ledslice1 CONFIG.DIN_FROM   1
ad_ip_parameter ledslice1 CONFIG.DIN_TO     1

ad_ip_instance xlslice ledslice2
ad_ip_parameter ledslice2 CONFIG.DIN_WIDTH  5
ad_ip_parameter ledslice2 CONFIG.DIN_FROM   4
ad_ip_parameter ledslice2 CONFIG.DIN_TO     2
ad_ip_parameter ledslice2 CONFIG.DOUT_WIDTH 3

ad_connect led_gpio/gpio_io_o ledslice0/Din
ad_connect led_gpio/gpio_io_o ledslice1/Din
ad_connect led_gpio/gpio_io_o ledslice2/Din
ad_connect ledslice0/Dout mux0/input_0
ad_connect ledslice1/Dout mux1/input_0

ad_ip_instance xlconcat ledconcat
ad_ip_parameter ledconcat CONFIG.NUM_PORTS 3
ad_connect mux0/dout       ledconcat/In0
ad_connect mux1/dout       ledconcat/In1
ad_connect ledslice2/Dout  ledconcat/In2
ad_connect ledconcat/dout  board_leds

###############################################################################
## PMOD GPIO × 16 (expansion data port spare pins)
###############################################################################

ad_ip_instance axi_gpio pmod_gpio
ad_ip_parameter pmod_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter pmod_gpio CONFIG.C_GPIO_WIDTH        16
ad_cpu_interconnect 0x411F0000 pmod_gpio
ad_connect sys_concat_intc/In6 pmod_gpio/ip2intc_irpt

create_bd_port -dir O -from 15 -to 0 pmod_gpio_o
create_bd_port -dir I -from 15 -to 0 pmod_gpio_i
create_bd_port -dir O -from 15 -to 0 pmod_gpio_t
ad_connect pmod_gpio_o pmod_gpio/gpio_io_o
ad_connect pmod_gpio_i pmod_gpio/gpio_io_i
ad_connect pmod_gpio_t pmod_gpio/gpio_io_t

###############################################################################
## External I2C (spare, no physical pins — ports exist for future use)
###############################################################################

ad_ip_instance axi_iic axi_iic_ext
ad_cpu_interconnect 0x41640000 axi_iic_ext
ad_connect sys_concat_intc/In13 axi_iic_ext/iic2intc_irpt

create_bd_port -dir I iic_ext_scl_i
create_bd_port -dir O iic_ext_scl_o
create_bd_port -dir O iic_ext_scl_t
create_bd_port -dir I iic_ext_sda_i
create_bd_port -dir O iic_ext_sda_o
create_bd_port -dir O iic_ext_sda_t
ad_connect axi_iic_ext/scl_i iic_ext_scl_i
ad_connect axi_iic_ext/scl_o iic_ext_scl_o
ad_connect axi_iic_ext/scl_t iic_ext_scl_t
ad_connect axi_iic_ext/sda_i iic_ext_sda_i
ad_connect axi_iic_ext/sda_o iic_ext_sda_o
ad_connect axi_iic_ext/sda_t iic_ext_sda_t

###############################################################################
## XADC (on-chip, identical to Zedboard)
###############################################################################

ad_ip_instance xadc_wiz xadc0
ad_cpu_interconnect 0x41650000 xadc0
ad_ip_parameter xadc0 CONFIG.ENABLE_AXI4STREAM        false
ad_ip_parameter xadc0 CONFIG.OT_ALARM                 false
ad_ip_parameter xadc0 CONFIG.USER_TEMP_ALARM          false
ad_ip_parameter xadc0 CONFIG.VCCINT_ALARM             false
ad_ip_parameter xadc0 CONFIG.VCCAUX_ALARM             false
ad_ip_parameter xadc0 CONFIG.ENABLE_VCCPINT_ALARM     false
ad_ip_parameter xadc0 CONFIG.ENABLE_VCCPAUX_ALARM     false
ad_ip_parameter xadc0 CONFIG.ENABLE_VCCDDRO_ALARM     false
ad_ip_parameter xadc0 CONFIG.ENABLE_EXTERNAL_MUX      false
ad_ip_parameter xadc0 CONFIG.SEQUENCER_MODE           Off
ad_ip_parameter xadc0 CONFIG.EXTERNAL_MUX_CHANNEL     VP_VN
ad_connect xadc0/ip2intc_irpt sys_concat_intc/In8
