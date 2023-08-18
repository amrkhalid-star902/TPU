`timescale 1ns / 1ps



module weightFIFO(clk , reset , en , weightIn , weightOut);

    parameter DATA_WIDTH = 8;  // must be same as DATA_WIDTH in dff8.v
    parameter FIFO_INPUTS = 4;
    localparam FIFO_WIDTH = DATA_WIDTH*FIFO_INPUTS;  // number of output weights
    parameter FIFO_DEPTH = 4;  // number of stage weights
    
    
    input clk;
    input reset;
    input [FIFO_INPUTS-1:0] en;  // MSB is leftmost column in the array
    input [FIFO_WIDTH-1:0] weightIn;  // MSB is leftmost column in the array
    output wire [FIFO_WIDTH-1:0] weightOut;  // LSB is leftmost column in the array

    wire [FIFO_INPUTS*FIFO_DEPTH-1:0] colEn;  // enable signals to be sent to each element in a respective column
    wire [FIFO_WIDTH*FIFO_DEPTH-1:0] dffIn;  // inputs to each element of dff array
    wire [FIFO_WIDTH*FIFO_DEPTH-1:0] dffOut;   // ouputs of each element of dff array
    
    
    dff dffArray[FIFO_INPUTS*FIFO_DEPTH-1 : 0](
    
        .clk(clk),
        .reset(reset),
        .en(colEn),
        .d(dffIn),
        .q(dffOut)
    
    );
    
    assign dffIn[FIFO_WIDTH-1 : 0] = weightIn;
    assign weightOut = dffOut[FIFO_WIDTH*FIFO_DEPTH-1 : FIFO_WIDTH*(FIFO_DEPTH-1)];
    
    
    generate
        
        genvar i;
        for(i = 1 ; i < FIFO_DEPTH ; i = i + 1)
        begin : generateConn
            
            assign dffIn[FIFO_WIDTH*(i+1)-1:FIFO_WIDTH*i] = dffOut[FIFO_WIDTH*i-1:FIFO_WIDTH*(i-1)];    
        
        end
        
        
        
    
    endgenerate
    
    
    generate
    
        genvar j;
        for(i = 0 ; i < FIFO_INPUTS ; i = i + 1) begin : widthIDX
            for(j = 0 ; j < FIFO_DEPTH ; j = j + 1) begin : depthIDX    
                
                assign colEn[j*FIFO_DEPTH+i] = en[i];
            
            end
        
        end
    
    endgenerate

endmodule
