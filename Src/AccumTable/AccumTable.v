`timescale 1ns / 1ps



module AccumTable(

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
    parameter SYS_ARR_ROWS   = 16;
    parameter SYS_ARR_COLS   = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_ROWS_NUM * (MAX_OUT_COLS/SYS_ARR_COLS);

    
    input  clk;
    input  [SYS_ARR_COLS-1 : 0] clear;
    input  [SYS_ARR_COLS-1 : 0] rd_en;
    input  [SYS_ARR_COLS-1 : 0] wr_en; 
    input  [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1 : 0] rd_address;
    input  [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1 : 0] wr_address;
    output wire signed [DATA_WIDTH*SYS_ARR_COLS-1 : 0] rd_data;
    input  signed [DATA_WIDTH*SYS_ARR_COLS-1 : 0] wr_data;
    
    
    AccumCol ArrayCol [SYS_ARR_COLS-1:0](
    
        .clk(clk),
        .clear(clear),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .rd_address(rd_address),
        .wr_address(wr_address),
        .rd_data(rd_data),
        .wr_data(wr_data)
        
    );
    
    
endmodule
