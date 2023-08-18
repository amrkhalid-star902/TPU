`timescale 1ns / 1ps


module AccumCol(

    clk,
    clear,
    rd_en,
    wr_en,
    rd_address,
    wr_address,
    rd_data,
    wr_data
    
);

    parameter DATA_WIDTH     = 16;   //Each piece of data is 16 bits wide
    parameter MAX_ROWS_NUM   = 128;  //The height of largest possible matrix
    parameter MAX_OUT_COLS   = 128;  //The width of largest possible matrix
    parameter SYS_ARR_COLS   = 16;    // Height of the systollic array
    
    //Each row will contain systollic array of number equal to the number of columns 
    //in the input matrix divided the total columns number of the systollic array
    //The total number of rows needed for accumulation process will be equal to the 
    //number of systollic array per row multiplyed by the number of rows of the input matrix.
    localparam NUM_ACCUM_ROWS = MAX_ROWS_NUM * (MAX_OUT_COLS/SYS_ARR_COLS);

    input  clk;
    input  clear;
    input  rd_en;
    input  wr_en;
    input  [$clog2(NUM_ACCUM_ROWS)-1 : 0] rd_address;
    input  [$clog2(NUM_ACCUM_ROWS)-1 : 0] wr_address;
    output reg signed [DATA_WIDTH-1 : 0] rd_data;
    input  signed [DATA_WIDTH-1 : 0] wr_data;
    
    reg [DATA_WIDTH-1 : 0] mem [NUM_ACCUM_ROWS-1 : 0];
    
    integer i;
    
    always@(posedge clk)
    begin
    
        if(wr_en)
        begin
            
            mem[wr_address] <= mem[wr_address] + wr_data;
        
        end
        
        if(rd_en)
        begin
            
            rd_data <= mem[rd_address];
        
        end
        
        if(clear)
        begin
        
            for(i = 0 ; i < NUM_ACCUM_ROWS ; i = i + 1)
            begin
                
                mem[i] <= 0;
            
            end
        
        end
    
    
    end

endmodule
