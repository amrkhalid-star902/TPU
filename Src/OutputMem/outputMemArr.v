
`timescale 1ns / 1ps


module outputMemArr(
    
    clk,
    rd_en,
    wr_en,
    wr_data,
    rd_data,
    wr_addr,
    rd_addr
    
);

    parameter  WIDTH_HEIGHT = 4;
    localparam enable_bits  = WIDTH_HEIGHT;
    
    input clk;
    input [enable_bits-1 : 0] rd_en;
    input [enable_bits-1 : 0] wr_en;
    input [(WIDTH_HEIGHT*16)-1 : 0] wr_data;
    input [(WIDTH_HEIGHT*8)-1 : 0] rd_addr;
    input [(WIDTH_HEIGHT*8)-1 : 0] wr_addr;
    output wire [(WIDTH_HEIGHT*16)-1 : 0] rd_data;
    
    genvar i;
    generate
    
        for(i = 0 ; i < WIDTH_HEIGHT ; i = i + 1) begin : memory_generate
            
            output_mem output_memory(
            
              .clock(clk),
              .data(wr_data[((i*16) + 16)-1 : (i*16)]),
              .rdaddress(rd_addr[((i*8) + 8)-1 : (i*8)]),
              .rden(rd_en[i]),
              .wraddress(wr_addr[((i*8) + 8)-1 : (i*8)]),
              .wren(wr_en[i]),
              .q(rd_data[((i*16) + 16)-1 : (i*16)])
              
            );

            
        end
    
    endgenerate


endmodule
