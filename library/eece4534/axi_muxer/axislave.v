`define SOURCE_VALUE_INDEX 0
module mux_axislave
#(
parameter integer C_S_AXI_DATA_WIDTH = 32,
parameter integer C_S_AXI_ADDR_WIDTH = 3
)
(
input  S_AXI_ACLK,
input  S_AXI_ARESETN,
input [(C_S_AXI_ADDR_WIDTH-1):0] S_AXI_AWADDR,
input [2:0] S_AXI_AWPROT,
input  S_AXI_AWVALID,
output  S_AXI_AWREADY,
input [(C_S_AXI_DATA_WIDTH-1):0] S_AXI_WDATA,
input [((C_S_AXI_DATA_WIDTH/8)-1):0] S_AXI_WSTRB,
input  S_AXI_WVALID,
output  S_AXI_WREADY,
output [1:0] S_AXI_BRESP,
output  S_AXI_BVALID,
input  S_AXI_BREADY,
input [(C_S_AXI_ADDR_WIDTH-1):0] S_AXI_ARADDR,
input [2:0] S_AXI_ARPROT,
input  S_AXI_ARVALID,
output  S_AXI_ARREADY,
output [(C_S_AXI_DATA_WIDTH-1):0] S_AXI_RDATA,
output [1:0] S_AXI_RRESP,
output  S_AXI_RVALID,
input  S_AXI_RREADY,
output [7:0] SRC_SEL
);
    reg [(C_S_AXI_ADDR_WIDTH-1):0] axi_awaddr;
    reg  axi_awready;
    reg  axi_wready;
    reg [1:0] axi_bresp;
    reg  axi_bvalid;
    reg [(C_S_AXI_ADDR_WIDTH-1):0] axi_araddr;
    reg  axi_arready;
    reg [(C_S_AXI_DATA_WIDTH-1):0] axi_rdata;
    reg [1:0] axi_rresp;
    reg  axi_rvalid;
    localparam  ADDR_LSB = ((C_S_AXI_DATA_WIDTH/32)+1);
    localparam  OPT_MEM_ADDR_BITS = 1'b1;
    //Register Space
    reg [31:0] REG_SOURCE;
    localparam [31:0] WRMASK_SOURCE = 32'h000000FF;
    wire  slv_reg_rden;
    wire  slv_reg_wren;
    reg [(C_S_AXI_DATA_WIDTH-1):0] reg_data_out;
    integer  byte_index;
    //I/O Connection assignments
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA = axi_rdata;
    assign S_AXI_RRESP = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;
    //User logic
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_awready <= 1'h0;
        end
        else begin
            if (((~axi_awready&&S_AXI_AWVALID)&&S_AXI_WVALID)) begin
                axi_awready <= 1'h1;
            end
            else begin
                axi_awready <= 1'h0;
            end
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_awaddr <= 1'h0;
        end
        else begin
            if (((~axi_awready&&S_AXI_AWVALID)&&S_AXI_WVALID)) begin
                axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_wready <= 1'h0;
        end
        else begin
            if (((~axi_awready&&S_AXI_AWVALID)&&S_AXI_WVALID)) begin
                axi_wready <= 1'h1;
            end
            else begin
                axi_wready <= 1'h0;
            end
        end
    end

    //generate slave write enable
    assign slv_reg_wren = (((axi_wready&&S_AXI_WVALID)&&axi_awready)&&S_AXI_AWVALID);
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            //Reset Registers
            REG_SOURCE <= 32'h00000000;
        end
        else begin
            if (slv_reg_wren) begin
                case (axi_awaddr[((ADDR_LSB+OPT_MEM_ADDR_BITS)-1):ADDR_LSB])
                default: begin
                    REG_SOURCE <= REG_SOURCE;
                end
                1'h0: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_SOURCE[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end

                end

                endcase

            end
        end
    end

    //Write response logic
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_bvalid <= 1'h0;
            axi_bresp <= 1'h0;
        end
        else begin
            if (((((axi_awready&&S_AXI_AWVALID)&&~axi_bvalid)&&axi_wready)&&S_AXI_WVALID)) begin
                axi_bvalid <= 1'h1;
                axi_bresp <= 1'h0;
            end
            else begin
                if ((S_AXI_BREADY&&axi_bvalid)) begin
                    axi_bvalid <= 1'h0;
                end
            end
        end
    end

    //axi_arready generation
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_arready <= 1'h0;
            axi_araddr <= 1'h0;
        end
        else begin
            if ((~axi_arready&&S_AXI_ARVALID)) begin
                axi_arready <= 1'h1;
                axi_araddr <= S_AXI_ARADDR;
            end
            else begin
                axi_arready <= 1'h0;
            end
        end
    end

    //arvalid generation
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_rvalid <= 1'h0;
            axi_rresp <= 1'h0;
        end
        else begin
            if (((axi_arready&&S_AXI_ARVALID)&&~axi_rvalid)) begin
                axi_rvalid <= 1'h1;
                axi_rresp <= 1'h0;
            end
            else begin
                if ((axi_rvalid&&S_AXI_RREADY)) begin
                    axi_rvalid <= 1'h0;
                end
            end
        end
    end

    //Register select and read logic
    assign slv_reg_rden = ((axi_arready&S_AXI_ARVALID)&~axi_rvalid);
    always @(*) begin
        if (S_AXI_ARESETN == 0) begin
            reg_data_out <= 1'h0;
        end
        else begin
            case (axi_araddr[((ADDR_LSB+OPT_MEM_ADDR_BITS)-1):ADDR_LSB])
            default: begin
                reg_data_out <= 1'h0;
            end
            1'h0: begin
                reg_data_out <= {24'b000000000000000000000000, REG_SOURCE[7:0]};
            end

            endcase

        end
    end

    //data output
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_rdata <= 1'h0;
        end
        else begin
            if (slv_reg_rden) begin
                axi_rdata <= reg_data_out;
            end
        end
    end

    //Output assignment
    assign SRC_SEL = REG_SOURCE[7:0];
endmodule
