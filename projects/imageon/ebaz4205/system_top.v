// ***************************************************************************
// Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
//
// EBAZ4205 minimum system top-level.
// Port names match system_wrapper output exactly (verified from wrapper.v).
// BD handles 8-bit GMII <-> 4-bit MII via xlslice/xlconcat internally.
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  // DDR (xc7z010 = 16-bit)
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

  // ENET0 EMIO MII -- port names match BD ports and XDC
  input   [ 3:0]  ENET0_GMII_RXD_0,
  input           ENET0_GMII_RX_CLK_0,
  input           ENET0_GMII_RX_DV_0,
  input           ENET0_GMII_TX_CLK_0,
  output  [ 3:0]  ENET0_GMII_TXD_0,
  output  [ 0:0]  ENET0_GMII_TX_EN_0,

  // MDIO (wrapper has internal iobuf; mdio_io is inout to board pin)
  output          MDIO_ETHERNET_0_0_mdc,
  inout           MDIO_ETHERNET_0_0_mdio_io

);

  // GPIO EMIO unused in minimum system
  wire  [63:0]  gpio_i;
  wire  [63:0]  gpio_o;
  wire  [63:0]  gpio_t;
  assign gpio_i = 64'h0;

  system_wrapper i_system_wrapper (

    .ddr_addr                     (ddr_addr),
    .ddr_ba                       (ddr_ba),
    .ddr_cas_n                    (ddr_cas_n),
    .ddr_ck_n                     (ddr_ck_n),
    .ddr_ck_p                     (ddr_ck_p),
    .ddr_cke                      (ddr_cke),
    .ddr_cs_n                     (ddr_cs_n),
    .ddr_dm                       (ddr_dm),
    .ddr_dq                       (ddr_dq),
    .ddr_dqs_n                    (ddr_dqs_n),
    .ddr_dqs_p                    (ddr_dqs_p),
    .ddr_odt                      (ddr_odt),
    .ddr_ras_n                    (ddr_ras_n),
    .ddr_reset_n                  (ddr_reset_n),
    .ddr_we_n                     (ddr_we_n),

    .fixed_io_ddr_vrn             (fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp             (fixed_io_ddr_vrp),
    .fixed_io_mio                 (fixed_io_mio),
    .fixed_io_ps_clk              (fixed_io_ps_clk),
    .fixed_io_ps_porb             (fixed_io_ps_porb),
    .fixed_io_ps_srstb            (fixed_io_ps_srstb),

    .ENET0_GMII_RXD_0             (ENET0_GMII_RXD_0),
    .ENET0_GMII_RX_CLK_0          (ENET0_GMII_RX_CLK_0),
    .ENET0_GMII_RX_DV_0           (ENET0_GMII_RX_DV_0),
    .ENET0_GMII_TX_CLK_0          (ENET0_GMII_TX_CLK_0),
    .ENET0_GMII_TXD_0             (ENET0_GMII_TXD_0),
    .ENET0_GMII_TX_EN_0           (ENET0_GMII_TX_EN_0),

    .MDIO_ETHERNET_0_0_mdc        (MDIO_ETHERNET_0_0_mdc),
    .MDIO_ETHERNET_0_0_mdio_io    (MDIO_ETHERNET_0_0_mdio_io),

    .gpio_i                       (gpio_i),
    .gpio_o                       (gpio_o),
    .gpio_t                       (gpio_t)
  );

endmodule
