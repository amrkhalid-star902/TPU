`timescale 1ns / 1ps



module tb_fifio(

    input clk,
    input reset,
    output wire [127:0] weight_out
);

    reg [127:0] weightIn;
    
    initial begin
    
        weightIn = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
                   8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16}; 
                   
        #1100;
        
       weightIn = {8'd3, 8'd4, 8'd1, 8'd10, 8'd13, 8'd15, 8'd2, 8'd5, 8'd6,
                   8'd10, 8'd11, 8'd12, 8'd6, 8'd5, 8'd10, 8'd12}; 
    
    end
    
    
    weightFIFO tb_weight_fifo (.clk(clk) , .reset(reset) , .en(16'hffff) , .weightIn(weightIn) , .weightOut(weight_out));
    
    defparam tb_weight_fifo.FIFO_INPUTS = 16;
    defparam tb_weight_fifo.FIFO_DEPTH = 16;
    
            


endmodule
