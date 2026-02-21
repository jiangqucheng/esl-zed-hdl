###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
##
## Modified for EECE4534/ESL: Zedboard standalone (no FMC-IMAGEON board).
## - Uses zed_system_bd.tcl as-is for HDMI TX (ADV7511 onboard), I2S, SPDIF TX.
## - imageon_bd.tcl is NOT sourced (removes HDMI RX, SPDIF RX, iic_imageon).
## - Adds EECE4534 board peripherals.
###############################################################################

source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

###############################################################################
## EECE4534 board peripherals
###############################################################################

# zed_system_bd.tcl ties all unused concat intc inputs to GND.
# Disconnect the slots we need before connecting real interrupt sources.
# Slots fixed by zed_system_bd: In15=hdmi_dma, In14=axi_iic_main, In11=axi_iic_fmc
# We take: In0,In1,In3,In4,In5,In6,In7,In8,In13

foreach intc_in {In0 In1 In3 In4 In5 In6 In7 In8 In13} {
  disconnect_bd_net \
    [get_bd_nets -of_objects [get_bd_pins sys_concat_intc/$intc_in]] \
    [get_bd_pins sys_concat_intc/$intc_in]
}

# --- LED GPIO (8x output + 4x oled_ctl via gpio2) ---
ad_ip_instance axi_gpio led_gpio
ad_ip_parameter led_gpio CONFIG.C_ALL_OUTPUTS 1
ad_ip_parameter led_gpio CONFIG.C_GPIO_WIDTH 8
ad_ip_parameter led_gpio CONFIG.C_IS_DUAL 1
ad_ip_parameter led_gpio CONFIG.C_ALL_OUTPUTS_2 1
ad_ip_parameter led_gpio CONFIG.C_GPIO2_WIDTH 4
ad_cpu_interconnect 0x41200000 led_gpio

create_bd_port -dir O -from 7 -to 0 board_leds
create_bd_port -dir O -from 3 -to 0 oled_ctl
ad_connect oled_ctl led_gpio/gpio2_io_o
# board_leds driven by ledconcat below

# --- DIP Switch GPIO ---
ad_ip_instance axi_gpio dipsw_gpio
ad_ip_parameter dipsw_gpio CONFIG.C_ALL_INPUTS 1
ad_ip_parameter dipsw_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter dipsw_gpio CONFIG.C_GPIO_WIDTH 8
ad_cpu_interconnect 0x41210000 dipsw_gpio
ad_connect sys_concat_intc/In0 dipsw_gpio/ip2intc_irpt

create_bd_port -dir I -from 7 -to 0 board_sw
ad_connect board_sw dipsw_gpio/gpio_io_i

# --- Push Button GPIO ---
ad_ip_instance axi_gpio btn_gpio
ad_ip_parameter btn_gpio CONFIG.C_ALL_INPUTS 1
ad_ip_parameter btn_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter btn_gpio CONFIG.C_GPIO_WIDTH 5
ad_cpu_interconnect 0x41220000 btn_gpio
ad_connect sys_concat_intc/In1 btn_gpio/ip2intc_irpt

create_bd_port -dir I -from 4 -to 0 board_btn
ad_connect board_btn btn_gpio/gpio_io_i

# --- OLED SPI ---
ad_ip_instance axi_quad_spi oled_spi
ad_ip_parameter oled_spi CONFIG.C_USE_STARTUP_INT 0
ad_ip_parameter oled_spi CONFIG.C_USE_STARTUP 0
ad_ip_parameter oled_spi CONFIG.Multiples16 1
ad_cpu_interconnect 0x41230000 oled_spi
ad_connect sys_concat_intc/In3 oled_spi/ip2intc_irpt

create_bd_port -dir O oled_data
create_bd_port -dir O oled_sck
ad_connect oled_spi/io0_o  oled_data
ad_connect oled_spi/sck_o  oled_sck
ad_connect GND             oled_spi/io1_i
ad_connect sys_ps7/FCLK_CLK0 oled_spi/ext_spi_clk

# --- Timers ---
ad_ip_instance axi_timer tmr0
ad_ip_parameter tmr0 CONFIG.enable_timer2 1
ad_cpu_interconnect 0x41240000 tmr0

ad_ip_instance axi_timer tmr1
ad_ip_parameter tmr1 CONFIG.enable_timer2 1
ad_cpu_interconnect 0x41250000 tmr1

# capture timer 2
ad_ip_instance axi_timer tmr2
ad_ip_parameter tmr2 CONFIG.enable_timer2 1
ad_ip_parameter tmr2 CONFIG.TRIG1_ASSERT Active_Low
ad_cpu_interconnect 0x41280000 tmr2
ad_connect sys_concat_intc/In4 tmr2/interrupt

create_bd_port -dir I tmr_capture
create_bd_port -dir O tmr_generate
ad_connect tmr_capture tmr2/capturetrig0
ad_connect tmr_capture tmr2/capturetrig1
ad_connect tmr_generate tmr2/generateout0

# capture timer 3
ad_ip_instance axi_timer tmr3
ad_ip_parameter tmr3 CONFIG.enable_timer2 1
ad_ip_parameter tmr3 CONFIG.TRIG1_ASSERT Active_Low
ad_cpu_interconnect 0x41290000 tmr3
ad_connect sys_concat_intc/In5 tmr3/interrupt

# --- AXI Muxes (custom IP: library/eece4534/axi_muxer) ---
ad_ip_instance axi_mux mux0
ad_ip_parameter mux0 CONFIG.C_DATA_W 1
ad_ip_parameter mux0 CONFIG.C_INPUT_W 2
ad_cpu_interconnect 0x41260000 mux0
ad_connect tmr0/pwm0    mux0/input_1
ad_connect tmr3/capturetrig0 mux0/dout
ad_connect tmr3/capturetrig1 mux0/dout

ad_ip_instance axi_mux mux1
ad_ip_parameter mux1 CONFIG.C_DATA_W 1
ad_ip_parameter mux1 CONFIG.C_INPUT_W 2
ad_cpu_interconnect 0x41270000 mux1
ad_connect tmr1/pwm0    mux1/input_1

# --- UART Lite ---
ad_ip_instance axi_uartlite pluart0
ad_cpu_interconnect 0x412A0000 pluart0
ad_ip_parameter pluart0 CONFIG.C_BAUDRATE 19200
ad_connect sys_concat_intc/In7 pluart0/interrupt

create_bd_port -dir I uart_rxd
create_bd_port -dir O uart_txd
ad_connect uart_rxd pluart0/rx
ad_connect uart_txd pluart0/tx

# --- PWM concat ---
ad_ip_instance xlconcat pwmconcat
ad_connect tmr0/pwm0 pwmconcat/In0
ad_connect tmr1/pwm0 pwmconcat/In1

create_bd_port -dir O -from 1 -to 0 pwm_out
ad_connect pwm_out pwmconcat/dout

# --- LED slice + mux logic ---
ad_ip_instance xlslice ledslice0
ad_ip_parameter ledslice0 CONFIG.DIN_WIDTH 8
ad_ip_parameter ledslice0 CONFIG.DIN_FROM 0
ad_ip_parameter ledslice0 CONFIG.DIN_TO 0

ad_ip_instance xlslice ledslice1
ad_ip_parameter ledslice1 CONFIG.DIN_WIDTH 8
ad_ip_parameter ledslice1 CONFIG.DIN_FROM 1
ad_ip_parameter ledslice1 CONFIG.DIN_TO 1

ad_ip_instance xlslice ledslice2
ad_ip_parameter ledslice2 CONFIG.DIN_WIDTH 8
ad_ip_parameter ledslice2 CONFIG.DIN_FROM 7
ad_ip_parameter ledslice2 CONFIG.DIN_TO 2
ad_ip_parameter ledslice2 CONFIG.DOUT_WIDTH 6

ad_connect led_gpio/gpio_io_o ledslice0/Din
ad_connect led_gpio/gpio_io_o ledslice1/Din
ad_connect led_gpio/gpio_io_o ledslice2/Din
ad_connect ledslice0/Dout mux0/input_0
ad_connect ledslice1/Dout mux1/input_0

ad_ip_instance xlconcat ledconcat
ad_ip_parameter ledconcat CONFIG.NUM_PORTS 3
ad_connect mux0/dout      ledconcat/In0
ad_connect mux1/dout      ledconcat/In1
ad_connect ledslice2/Dout ledconcat/In2
ad_connect ledconcat/dout board_leds

# --- PMOD GPIO ---
ad_ip_instance axi_gpio pmod_gpio
ad_ip_parameter pmod_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter pmod_gpio CONFIG.C_GPIO_WIDTH 16
ad_cpu_interconnect 0x411F0000 pmod_gpio
ad_connect sys_concat_intc/In6 pmod_gpio/ip2intc_irpt

create_bd_port -dir O -from 15 -to 0 pmod_gpio_o
create_bd_port -dir I -from 15 -to 0 pmod_gpio_i
create_bd_port -dir O -from 15 -to 0 pmod_gpio_t
ad_connect pmod_gpio_o pmod_gpio/gpio_io_o
ad_connect pmod_gpio_i pmod_gpio/gpio_io_i
ad_connect pmod_gpio_t pmod_gpio/gpio_io_t

# --- External I2C ---
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

# --- XADC ---
ad_ip_instance xadc_wiz xadc0
ad_cpu_interconnect 0x41650000 xadc0
ad_ip_parameter xadc0 CONFIG.ENABLE_AXI4STREAM false
ad_ip_parameter xadc0 CONFIG.OT_ALARM false
ad_ip_parameter xadc0 CONFIG.USER_TEMP_ALARM false
ad_ip_parameter xadc0 CONFIG.VCCINT_ALARM false
ad_ip_parameter xadc0 CONFIG.VCCAUX_ALARM false
ad_ip_parameter xadc0 CONFIG.ENABLE_VCCPINT_ALARM false
ad_ip_parameter xadc0 CONFIG.ENABLE_VCCPAUX_ALARM false
ad_ip_parameter xadc0 CONFIG.ENABLE_VCCDDRO_ALARM false
ad_ip_parameter xadc0 CONFIG.ENABLE_EXTERNAL_MUX false
ad_ip_parameter xadc0 CONFIG.SEQUENCER_MODE Off
ad_ip_parameter xadc0 CONFIG.EXTERNAL_MUX_CHANNEL VP_VN
ad_connect xadc0/ip2intc_irpt sys_concat_intc/In8
