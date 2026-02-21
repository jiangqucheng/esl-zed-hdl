module axi_mux
  #(
    parameter integer C_DATA_W = 1,
    parameter integer C_INPUT_W = 2
  )
   (
    // axi
    input              s_axi_aclk,
    input              s_axi_aresetn,
    input              s_axi_awvalid,
    input [ 15:0]      s_axi_awaddr,
    output             s_axi_awready,
    input              s_axi_wvalid,
    input [ 31:0]      s_axi_wdata,
    input [ 3:0]       s_axi_wstrb,
    output             s_axi_wready,
    output             s_axi_bvalid,
    output [ 1:0]      s_axi_bresp,
    input              s_axi_bready,
    input              s_axi_arvalid,
    input [ 15:0]      s_axi_araddr,
    output             s_axi_arready,
    output             s_axi_rvalid,
    output [ 31:0]     s_axi_rdata,
    output [ 1:0]      s_axi_rresp,
    input              s_axi_rready,
    input [ 2:0]       s_axi_awprot,
    input [ 2:0]       s_axi_arprot,

    input [C_DATA_W-1:0] input_0,
    input [C_DATA_W-1:0] input_1,
    input [C_DATA_W-1:0] input_2,
    input [C_DATA_W-1:0] input_3,
    input [C_DATA_W-1:0] input_4,
    input [C_DATA_W-1:0] input_5,
    input [C_DATA_W-1:0] input_6,
    input [C_DATA_W-1:0] input_7,
    output [C_DATA_W-1:0] dout
    );

   wire [7:0]      src_selector;

   //multiplex please
   assign dout = (src_selector == 0) ? input_0 : (src_selector == 1) ? input_1 : (src_selector == 2) ? input_2 :
                 (src_selector == 3) ? input_3 : (src_selector == 4) ? input_4 : (src_selector == 5) ? input_5 :
                 (src_selector == 6) ? input_6 : (src_selector == 7) ? input_7 : 'b0;

   mux_axislave slv0
     (
      .S_AXI_ARESETN (s_axi_aresetn),
      .S_AXI_ACLK (s_axi_aclk),
      .S_AXI_AWVALID (s_axi_awvalid),
      .S_AXI_AWADDR (s_axi_awaddr),
      .S_AXI_AWREADY (s_axi_awready),
      .S_AXI_WVALID (s_axi_wvalid),
      .S_AXI_WDATA (s_axi_wdata),
      .S_AXI_WSTRB (s_axi_wstrb),
      .S_AXI_WREADY (s_axi_wready),
      .S_AXI_BVALID (s_axi_bvalid),
      .S_AXI_BRESP (s_axi_bresp),
      .S_AXI_BREADY (s_axi_bready),
      .S_AXI_ARVALID (s_axi_arvalid),
      .S_AXI_ARADDR (s_axi_araddr),
      .S_AXI_ARREADY (s_axi_arready),
      .S_AXI_RVALID (s_axi_rvalid),
      .S_AXI_RRESP (s_axi_rresp),
      .S_AXI_RDATA (s_axi_rdata),
      .S_AXI_RREADY (s_axi_rready),
      .SRC_SEL (src_selector)
      );

endmodule
