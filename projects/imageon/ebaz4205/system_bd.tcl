###############################################################################
## imageon/ebaz4205/system_bd.tcl
##
## Peripheral map (mirrors imageon/zed/system_bd.tcl where possible):
##   0x41208000  board_led_gpio  (2-bit: W13 green, W14 red — separate IP)
##   0x41200000  led_gpio        (8-bit: E19/K17/H18/G20/J18/G19/H20/J19)
##   0x41210000  dipsw_gpio      (8-bit in, 8x SW on expansion board)
##   0x41220000  btn_gpio        (5-bit in, expansion buttons)
##   0x41230000  lcd_spi         (SPI to LCD ST7789)
##   0x41240000  tmr0            (dual timer + PWM0)
##   0x41250000  tmr1            (dual timer + PWM1)
##   0x41260000  mux0            (1-bit 2-input mux)
##   0x41270000  mux1            (1-bit 2-input mux)
##   0x41280000  tmr2            (capture timer — J5_SPEED V15)
##   0x41290000  tmr3            (capture timer — J3_SPEED V13)
##   0x412A0000  pluart0         (UART Lite → CH340, 115200 baud)
##   0x41600000  axi_iic_main    (I2C master, SCL=P18 SDA=M17)
##   0x41640000  axi_iic_ext     (spare I2C, physical pins)
##   0x41650000  xadc0           (on-chip temperature/voltage)
##   0x45000000  axi_sysid_0
##   0x75c00000  axi_spdif_tx_core
##   0x77600000  axi_i2s_adi
##
## I2S pin map (PCM5102A, 3-wire mode — no SCK needed):
##   BCK   = M19 (DATA3_5)
##   LRCK  = N20 (DATA3_6)
##   DIN   = P18 (DATA3_7)  [FPGA SDATA_OUT → DAC DIN]
##   MCLK  = L17 (DATA2_20) [optional, chip has internal PLL]
##
## I2C pin map (axi_iic_main):
##   SCL = M17 (DATA3_8)
##   SDA = (DATA3 last spare, see note below)
##
## SW pin map (dipsw_gpio, 8 inputs):
##   sw[0..7] = K18/K19/J20/L16/L19/M18/L20/M20 (DATA2_11..19)
##
## EXT LED pin map (led_gpio, 8 outputs):
##   ext_led[0..2] = E19/K17/H18 (DATA1_18/20/15, existing)
##   ext_led[3..7] = G20/J18/G19/H20/J19 (DATA2_5..9, new)
##
## Note: I2C uses PS7 I2C0 (MIO 26/27) = /dev/i2c-0 instead of axi_iic_main
##   to save 2 pins. axi_iic_ext reuses old axi_iic_main address for compat.
###############################################################################

source $ad_hdl_dir/projects/common/ebaz4205/ebaz4205_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

# system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0   CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0   CONFIG.ROM_ADDR_BITS 9
sysid_gen_sys_init_file

## GPIO EMIO: 물리 핀 없음 — BD 포트 제거 후 내부 constant로 처리
## (Vivado가 64비트를 IO 핀으로 추출하는 것을 방지)
delete_bd_objs [get_bd_ports gpio_i]
delete_bd_objs [get_bd_ports gpio_o]
delete_bd_objs [get_bd_ports gpio_t]
ad_ip_instance xlconstant gpio_i_tie
ad_ip_parameter gpio_i_tie CONFIG.CONST_VAL   {0}
ad_ip_parameter gpio_i_tie CONFIG.CONST_WIDTH {64}
disconnect_bd_net [get_bd_nets -of_objects [get_bd_pins sys_ps7/GPIO_I]] [get_bd_pins sys_ps7/GPIO_I]
ad_connect gpio_i_tie/dout sys_ps7/GPIO_I


###############################################################################
## Disconnect interrupt slots
## Slots: In0=dipsw, In1=btn, In3=lcd_spi, In4=tmr2, In5=tmr3,
##        In6=ext_led, In7=pluart0, In8=xadc, In13=iic_ext, In14=iic_main
##        DMA: In15=spdif, In12=i2s_tx, (board_led has no irq)
###############################################################################

foreach intc_in {In0 In1 In3 In4 In5 In6 In7 In8 In13 In14} {
  disconnect_bd_net \
    [get_bd_nets -of_objects [get_bd_pins sys_concat_intc/$intc_in]] \
    [get_bd_pins sys_concat_intc/$intc_in]
}

###############################################################################
## Board LED GPIO — 2-bit (W13 green, W14 red), separate IP for independent
## software control. No interrupt needed.
###############################################################################

ad_ip_instance axi_gpio board_led_gpio
ad_ip_parameter board_led_gpio CONFIG.C_ALL_OUTPUTS 1
ad_ip_parameter board_led_gpio CONFIG.C_GPIO_WIDTH  2
ad_cpu_interconnect 0x41208000 board_led_gpio

create_bd_port -dir O -from 1 -to 0 board_led
ad_connect board_led board_led_gpio/gpio_io_o

###############################################################################
## Extension LED GPIO — 8-bit output
## [0..2] = E19/K17/H18 (existing ext LEDs on expansion board)
## [3..7] = G20/J18/G19/H20/J19 (DATA2_5..9, newly added)
###############################################################################

ad_ip_instance axi_gpio led_gpio
ad_ip_parameter led_gpio CONFIG.C_ALL_OUTPUTS   1
ad_ip_parameter led_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter led_gpio CONFIG.C_GPIO_WIDTH    8
ad_ip_parameter led_gpio CONFIG.C_IS_DUAL       1
ad_ip_parameter led_gpio CONFIG.C_ALL_OUTPUTS_2 1
ad_ip_parameter led_gpio CONFIG.C_GPIO2_WIDTH   3
ad_cpu_interconnect 0x41200000 led_gpio
ad_connect sys_concat_intc/In6 led_gpio/ip2intc_irpt

create_bd_port -dir O -from 7 -to 0 ext_led
create_bd_port -dir O -from 4 -to 0 lcd_ctl
## ext_led driven via ledconcat (mux routing), not directly from GPIO
ad_connect lcd_ctl  led_gpio/gpio2_io_o

###############################################################################
## DIP Switch GPIO — 8-bit input, physical SW pins on expansion board
###############################################################################

ad_ip_instance axi_gpio dipsw_gpio
ad_ip_parameter dipsw_gpio CONFIG.C_ALL_INPUTS        1
ad_ip_parameter dipsw_gpio CONFIG.C_INTERRUPT_PRESENT 1
ad_ip_parameter dipsw_gpio CONFIG.C_GPIO_WIDTH        8
ad_cpu_interconnect 0x41210000 dipsw_gpio
ad_connect sys_concat_intc/In0 dipsw_gpio/ip2intc_irpt

create_bd_port -dir I -from 7 -to 0 sw
ad_connect sw dipsw_gpio/gpio_io_i

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
## LCD SPI (ST7789)
###############################################################################

ad_ip_instance axi_quad_spi lcd_spi
ad_ip_parameter lcd_spi CONFIG.C_USE_STARTUP_INT 0
ad_ip_parameter lcd_spi CONFIG.C_USE_STARTUP     0
ad_ip_parameter lcd_spi CONFIG.Multiples16       1
ad_cpu_interconnect 0x41230000 lcd_spi
ad_connect sys_concat_intc/In3 lcd_spi/ip2intc_irpt

create_bd_port -dir O lcd_sda
create_bd_port -dir O lcd_scl
ad_connect lcd_spi/io0_o      lcd_sda
ad_connect lcd_spi/sck_o      lcd_scl
ad_connect GND                lcd_spi/io1_i
ad_connect sys_ps7/FCLK_CLK0 lcd_spi/ext_spi_clk

###############################################################################
## Timers
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
ad_connect tmr_capture  tmr2/capturetrig0
ad_connect tmr_capture  tmr2/capturetrig1

ad_ip_instance axi_timer tmr3
ad_ip_parameter tmr3 CONFIG.enable_timer2  1
ad_ip_parameter tmr3 CONFIG.TRIG1_ASSERT   Active_Low
ad_cpu_interconnect 0x41290000 tmr3
ad_connect sys_concat_intc/In5 tmr3/interrupt

###############################################################################
## AXI Mux × 2
###############################################################################

ad_ip_instance axi_mux mux0
ad_ip_parameter mux0 CONFIG.C_DATA_W  1
ad_ip_parameter mux0 CONFIG.C_INPUT_W 2
ad_cpu_interconnect 0x41260000 mux0
ad_connect tmr0/pwm0         mux0/input_1
## tmr3 driven by tmr_capture2 (J3_SPEED) exclusively
ad_connect tmr_capture2 tmr3/capturetrig1
ad_connect tmr_capture2      tmr3/capturetrig0

ad_ip_instance axi_mux mux1
ad_ip_parameter mux1 CONFIG.C_DATA_W  1
ad_ip_parameter mux1 CONFIG.C_INPUT_W 2
ad_cpu_interconnect 0x41270000 mux1
ad_connect tmr1/pwm0 mux1/input_1

###############################################################################
## UART Lite → CH340
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
## PWM output × 2 (J5=V12, J3=U12 via optocoupler)
###############################################################################

ad_ip_instance xlconcat pwmconcat
ad_connect tmr0/pwm0 pwmconcat/In0
ad_connect tmr1/pwm0 pwmconcat/In1
create_bd_port -dir O -from 1 -to 0 pwm_out
ad_connect pwm_out pwmconcat/dout

###############################################################################
## LED slice + mux routing for ext_led (8-bit) → board_leds mux logic
## Uses ext_led[0] and ext_led[1] as inputs to mux0/mux1 (same as Zedboard
## where led[0]/led[1] feed mux input_0)
###############################################################################

ad_ip_instance xlslice ledslice0
ad_ip_parameter ledslice0 CONFIG.DIN_WIDTH  8
ad_ip_parameter ledslice0 CONFIG.DIN_FROM   0
ad_ip_parameter ledslice0 CONFIG.DIN_TO     0

ad_ip_instance xlslice ledslice1
ad_ip_parameter ledslice1 CONFIG.DIN_WIDTH  8
ad_ip_parameter ledslice1 CONFIG.DIN_FROM   1
ad_ip_parameter ledslice1 CONFIG.DIN_TO     1

ad_ip_instance xlslice ledslice2
ad_ip_parameter ledslice2 CONFIG.DIN_WIDTH  8
ad_ip_parameter ledslice2 CONFIG.DIN_FROM   7
ad_ip_parameter ledslice2 CONFIG.DIN_TO     2
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
ad_connect ledconcat/dout ext_led

###############################################################################
## I2C main (axi_iic_main) — physical pins: SCL=M17(DATA3_8), SDA=L17(DATA2_20)
## Mirrors Zedboard axi_iic_main at 0x41600000
###############################################################################

ad_ip_instance axi_iic axi_iic_main
ad_ip_parameter axi_iic_main CONFIG.USE_BOARD_FLOW true
ad_ip_parameter axi_iic_main CONFIG.IIC_BOARD_INTERFACE Custom
ad_cpu_interconnect 0x41600000 axi_iic_main
ad_connect sys_concat_intc/In14 axi_iic_main/iic2intc_irpt

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_main
ad_connect axi_iic_main/IIC iic_main

###############################################################################
## Spare I2C (axi_iic_ext) — physical pins on expansion header (no XDC yet)
###############################################################################

ad_ip_instance axi_iic axi_iic_ext
ad_cpu_interconnect 0x41640000 axi_iic_ext
ad_connect sys_concat_intc/In13 axi_iic_ext/iic2intc_irpt

## iic_ext: 물리 핀 미확정 — IIC 인터페이스를 GND/VCC로 tie
ad_ip_instance xlconstant iic_ext_scl_tie
ad_ip_parameter iic_ext_scl_tie CONFIG.CONST_VAL   1
ad_ip_parameter iic_ext_scl_tie CONFIG.CONST_WIDTH 1
ad_ip_instance xlconstant iic_ext_sda_tie
ad_ip_parameter iic_ext_sda_tie CONFIG.CONST_VAL   1
ad_ip_parameter iic_ext_sda_tie CONFIG.CONST_WIDTH 1
ad_connect iic_ext_scl_tie/dout axi_iic_ext/scl_i
ad_connect iic_ext_sda_tie/dout axi_iic_ext/sda_i

###############################################################################
## XADC
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

###############################################################################
## Audio: clock generator + SPDIF TX + I2S ADI
## DMA0 → SPDIF, DMA1 → I2S TX, DMA2 → I2S RX
## I2S pin map (3-wire, PCM5102A compatible):
##   i2s_mclk  = L17 (DATA2_20) — optional, PCM5102A has internal PLL
##   i2s_bclk  = M19 (DATA3_5)
##   i2s_lrclk = N20 (DATA3_6)
##   i2s_sdata_out = P18 (DATA3_7) → PCM5102A DIN
##   i2s_sdata_in  = no physical pin (DAC only, tie to GND internally)
###############################################################################

## Enable PS7 DMA0/1/2 for audio (overrides ebaz4205_system_bd.tcl defaults)
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA0 1
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA1 1
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_DMA2 1

ad_ip_instance clk_wiz sys_audio_clkgen
ad_ip_parameter sys_audio_clkgen CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 12.288
ad_ip_parameter sys_audio_clkgen CONFIG.USE_LOCKED false
ad_ip_parameter sys_audio_clkgen CONFIG.USE_RESET true
ad_ip_parameter sys_audio_clkgen CONFIG.USE_PHASE_ALIGNMENT false
ad_ip_parameter sys_audio_clkgen CONFIG.RESET_TYPE ACTIVE_LOW
ad_ip_parameter sys_audio_clkgen CONFIG.PRIM_SOURCE No_buffer
ad_connect sys_cpu_clk    sys_audio_clkgen/clk_in1
ad_connect sys_cpu_resetn sys_audio_clkgen/resetn

ad_ip_instance axi_spdif_tx axi_spdif_tx_core
ad_ip_parameter axi_spdif_tx_core CONFIG.DMA_TYPE           1
ad_ip_parameter axi_spdif_tx_core CONFIG.S_AXI_ADDRESS_WIDTH 16
ad_cpu_interconnect 0x75c00000 axi_spdif_tx_core
ad_connect sys_cpu_clk               axi_spdif_tx_core/DMA_REQ_ACLK
ad_connect sys_cpu_clk               sys_ps7/DMA0_ACLK
ad_connect sys_cpu_resetn            axi_spdif_tx_core/DMA_REQ_RSTN
ad_connect sys_audio_clkgen/clk_out1 axi_spdif_tx_core/spdif_data_clk
ad_connect sys_ps7/DMA0_REQ          axi_spdif_tx_core/DMA_REQ
ad_connect sys_ps7/DMA0_ACK          axi_spdif_tx_core/DMA_ACK

ad_ip_instance axi_i2s_adi axi_i2s_adi
ad_ip_parameter axi_i2s_adi CONFIG.DMA_TYPE           1
ad_ip_parameter axi_i2s_adi CONFIG.S_AXI_ADDRESS_WIDTH 16
ad_cpu_interconnect 0x77600000 axi_i2s_adi
ad_connect sys_cpu_clk               axi_i2s_adi/DMA_REQ_RX_ACLK
ad_connect sys_cpu_clk               sys_ps7/DMA1_ACLK
ad_connect sys_cpu_clk               sys_ps7/DMA2_ACLK
ad_connect sys_cpu_clk               axi_i2s_adi/DMA_REQ_TX_ACLK
ad_connect sys_cpu_resetn            axi_i2s_adi/DMA_REQ_TX_RSTN
ad_connect sys_cpu_resetn            axi_i2s_adi/DMA_REQ_RX_RSTN
## I2S 개별 포트 — sdata_in 은 constant 0 으로 tie (PCM5102A는 DAC only)
create_bd_port -dir O i2s_bclk
create_bd_port -dir O i2s_lrclk
create_bd_port -dir O i2s_sdata_out
ad_ip_instance xlconstant i2s_sdata_gnd
ad_ip_parameter i2s_sdata_gnd CONFIG.CONST_VAL {0}
ad_ip_parameter i2s_sdata_gnd CONFIG.CONST_WIDTH {1}

ad_connect sys_audio_clkgen/clk_out1 axi_i2s_adi/DATA_CLK_I
ad_connect axi_i2s_adi/bclk_o    i2s_bclk
ad_connect axi_i2s_adi/lrclk_o   i2s_lrclk
ad_connect axi_i2s_adi/sdata_o   i2s_sdata_out
ad_connect i2s_sdata_gnd/dout    axi_i2s_adi/sdata_i
ad_connect sys_ps7/DMA1_REQ          axi_i2s_adi/DMA_REQ_TX
ad_connect sys_ps7/DMA1_ACK          axi_i2s_adi/DMA_ACK_TX
ad_connect sys_ps7/DMA2_REQ          axi_i2s_adi/DMA_REQ_RX
ad_connect sys_ps7/DMA2_ACK          axi_i2s_adi/DMA_ACK_RX
