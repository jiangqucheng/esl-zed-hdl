// ***************************************************************************
// Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
//
// EBAZ4205 + expansion board system top-level.
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  // DDR
  inout   [14:0]  ddr_addr,
  inout   [ 2:0]  ddr_ba,
  inout           ddr_cas_n,
  inout           ddr_ck_n,
  inout           ddr_ck_p,
  inout           ddr_cke,
  inout           ddr_cs_n,
  inout   [ 1:0]  ddr_dm,
  inout   [15:0]  ddr_dq,
  inout   [ 1:0]  ddr_dqs_n,
  inout   [ 1:0]  ddr_dqs_p,
  inout           ddr_odt,
  inout           ddr_ras_n,
  inout           ddr_reset_n,
  inout           ddr_we_n,

  // PS fixed IO
  inout           fixed_io_ddr_vrn,
  inout           fixed_io_ddr_vrp,
  inout   [53:0]  fixed_io_mio,
  inout           fixed_io_ps_clk,
  inout           fixed_io_ps_porb,
  inout           fixed_io_ps_srstb,

  // ENET0 EMIO MII
  input   [ 3:0]  ENET0_GMII_RXD_0,
  input           ENET0_GMII_RX_CLK_0,
  input           ENET0_GMII_RX_DV_0,
  input           ENET0_GMII_TX_CLK_0,
  output  [ 3:0]  ENET0_GMII_TXD_0,
  output  [ 0:0]  ENET0_GMII_TX_EN_0,
  output          MDIO_ETHERNET_0_0_mdc,
  inout           MDIO_ETHERNET_0_0_mdio_io,

  // LEDs: [1:0] on-board, [4:2] expansion
  output  [ 4:0]  board_leds,

  // Buttons: 5x expansion
  input   [ 4:0]  board_btn,

  // LCD ST7789 SPI + control
  output          lcd_scl,
  output          lcd_sda,
  output  [ 4:0]  lcd_ctl,    // [0]=DC, [1]=RST, [2]=BL, [4:3]=spare

  // CH340 UART
  input           uart_rxd,
  output          uart_txd,

  // PWM: [0]=J5_PWM(V12), [1]=J3_PWM(U12) — via fan header optocouplers
  output  [ 1:0]  pwm_out,

  // Timer capture/generate
  input           tmr_capture,   // J5_SPEED (V15) — J5 fan tach input
  input           tmr_capture2,  // J3_SPEED (V13) — J3 fan tach input
  output          tmr_generate,

  // PMOD GPIO 16-bit (DATA2 × 14 + DATA3 × 2)
  inout   [15:0]  pmod_gpio_buf,

  // External I2C (spare)
  inout           iic_ext_scl,
  inout           iic_ext_sda

);

  // GPIO EMIO (64-bit, unused in this design)
  wire  [63:0]  gpio_i;
  wire  [63:0]  gpio_o;
  wire  [63:0]  gpio_t;
  assign gpio_i = 64'h0;

  // PMOD 16-bit tri-state buffers
  wire  [15:0]  pmod_gpio_o;
  wire  [15:0]  pmod_gpio_i;
  wire  [15:0]  pmod_gpio_t;

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : pmod_iobuf
      ad_iobuf #(.DATA_WIDTH(1)) i_pmod_buf (
        .dio_t (pmod_gpio_t[i]),
        .dio_i (pmod_gpio_o[i]),
        .dio_o (pmod_gpio_i[i]),
        .dio_p (pmod_gpio_buf[i])
      );
    end
  endgenerate

  // External I2C tri-state
  wire  iic_ext_scl_i, iic_ext_scl_o, iic_ext_scl_t;
  wire  iic_ext_sda_i, iic_ext_sda_o, iic_ext_sda_t;

  ad_iobuf #(.DATA_WIDTH(1)) i_iic_scl (
    .dio_t (iic_ext_scl_t), .dio_i (iic_ext_scl_o),
    .dio_o (iic_ext_scl_i), .dio_p (iic_ext_scl)
  );
  ad_iobuf #(.DATA_WIDTH(1)) i_iic_sda (
    .dio_t (iic_ext_sda_t), .dio_i (iic_ext_sda_o),
    .dio_o (iic_ext_sda_i), .dio_p (iic_ext_sda)
  );

  // lcd_ctl [4:3] not driven by BD (only [2:0] used), tie to 0
  wire [4:0] lcd_ctl_bd;
  assign lcd_ctl = {2'b00, lcd_ctl_bd[2:0]};

  system_wrapper i_system_wrapper (

    .ddr_addr                   (ddr_addr),
    .ddr_ba                     (ddr_ba),
    .ddr_cas_n                  (ddr_cas_n),
    .ddr_ck_n                   (ddr_ck_n),
    .ddr_ck_p                   (ddr_ck_p),
    .ddr_cke                    (ddr_cke),
    .ddr_cs_n                   (ddr_cs_n),
    .ddr_dm                     (ddr_dm),
    .ddr_dq                     (ddr_dq),
    .ddr_dqs_n                  (ddr_dqs_n),
    .ddr_dqs_p                  (ddr_dqs_p),
    .ddr_odt                    (ddr_odt),
    .ddr_ras_n                  (ddr_ras_n),
    .ddr_reset_n                (ddr_reset_n),
    .ddr_we_n                   (ddr_we_n),

    .fixed_io_ddr_vrn           (fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp           (fixed_io_ddr_vrp),
    .fixed_io_mio               (fixed_io_mio),
    .fixed_io_ps_clk            (fixed_io_ps_clk),
    .fixed_io_ps_porb           (fixed_io_ps_porb),
    .fixed_io_ps_srstb          (fixed_io_ps_srstb),

    .ENET0_GMII_RXD_0           (ENET0_GMII_RXD_0),
    .ENET0_GMII_RX_CLK_0        (ENET0_GMII_RX_CLK_0),
    .ENET0_GMII_RX_DV_0         (ENET0_GMII_RX_DV_0),
    .ENET0_GMII_TX_CLK_0        (ENET0_GMII_TX_CLK_0),
    .ENET0_GMII_TXD_0           (ENET0_GMII_TXD_0),
    .ENET0_GMII_TX_EN_0         (ENET0_GMII_TX_EN_0),
    .MDIO_ETHERNET_0_0_mdc      (MDIO_ETHERNET_0_0_mdc),
    .MDIO_ETHERNET_0_0_mdio_io  (MDIO_ETHERNET_0_0_mdio_io),

    .board_leds                 (board_leds),
    .board_btn                  (board_btn),

    .lcd_scl                    (lcd_scl),
    .lcd_sda                    (lcd_sda),
    .lcd_ctl                    (lcd_ctl_bd[4:0]),

    .uart_rxd                   (uart_rxd),
    .uart_txd                   (uart_txd),

    .pwm_out                    (pwm_out),

    .tmr_capture                (tmr_capture),
    .tmr_capture2               (tmr_capture2),
    .tmr_generate               (tmr_generate),

    .pmod_gpio_o                (pmod_gpio_o),
    .pmod_gpio_i                (pmod_gpio_i),
    .pmod_gpio_t                (pmod_gpio_t),

    .iic_ext_scl_i              (iic_ext_scl_i),
    .iic_ext_scl_o              (iic_ext_scl_o),
    .iic_ext_scl_t              (iic_ext_scl_t),
    .iic_ext_sda_i              (iic_ext_sda_i),
    .iic_ext_sda_o              (iic_ext_sda_o),
    .iic_ext_sda_t              (iic_ext_sda_t),

    .gpio_i                     (gpio_i),
    .gpio_o                     (gpio_o),
    .gpio_t                     (gpio_t)
  );

endmodule
