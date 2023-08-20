`timescale 1ns / 1ps


module master_output_ctrl(
    
    clk,
    start,
    reset,
    submatrix_row_in,
    submatrix_col_in,
    submatrix_row_out,
    submatrix_col_out,
    read_rows_num,
    read_cols_num,
    row_num,
    clear_after,
    activate,
    accum_clear,
    relu_en,
    wr_base_addr,
    wr_en,
    wr_addr,
    done
    
);


    parameter MAX_OUT_ROWS = 128; 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    parameter ADDR_WIDTH = 8;
    
    localparam NUM_SUBMATS_M  = MAX_OUT_ROWS/SYS_ARR_ROWS; 
    localparam NUM_SUBMATS_N  = MAX_OUT_COLS/SYS_ARR_COLS;   
    
    input clk , start , reset;
    input [$clog2(NUM_SUBMATS_M)-1 : 0] submatrix_row_in;
    input [$clog2(NUM_SUBMATS_N)-1 : 0] submatrix_col_in;
    input [$clog2(SYS_ARR_ROWS)-1 : 0] read_rows_num;
    input [$clog2(SYS_ARR_COLS)-1 : 0] read_cols_num;
    input [ADDR_WIDTH-1 : 0] wr_base_addr;
    input activate;
    input clear_after;
    output [$clog2(NUM_SUBMATS_M)-1 : 0] submatrix_row_out;
    output [$clog2(NUM_SUBMATS_N)-1 : 0] submatrix_col_out;
    output [$clog2(SYS_ARR_ROWS)-1 : 0] row_num;
    output [ADDR_WIDTH*SYS_ARR_COLS-1 : 0] wr_addr;
    output reg [SYS_ARR_COLS-1 : 0] wr_en;
    output reg relu_en , accum_clear;
    output done;
    
    reg started , started_r;
    
    reg [$clog2(SYS_ARR_ROWS)-1 : 0] count , count_r;
    
    assign done = ~started;
    
    assign submatrix_row_out = submatrix_row_in;
    assign submatrix_col_out = submatrix_col_in;
    
    assign row_num = count;
    
    assign wr_addr = {SYS_ARR_COLS{wr_base_addr + count}};
    
    always@(posedge clk)
    begin
        
        count = count_r;
        started = started_r;
    
    end
    
    
    always@(*)
    begin
        
        count_r     = {$clog2(SYS_ARR_ROWS){1'b0}};
        started_r   = started;
        accum_clear = 1'b0;
        wr_en       = {SYS_ARR_COLS{1'b0}};
        relu_en     = 1'b0;
        
        if(start)
        begin
        
            started_r = 1'b1;
        
        end
        
        if(started)
        begin
        
            count_r = count + 1;
            wr_en = {SYS_ARR_COLS{1'b1}} >> (SYS_ARR_COLS - read_cols_num - 1);
            relu_en = activate;
            
            if(count == read_rows_num)
            begin
                
                started_r = 1'b0;
                count_r   = 0;
                
                if(clear_after)
                begin
                
                    accum_clear = 1'b1;
                    
                end
                
            end
            
        end
        
        if(reset)
        begin
        
            count_r = 0;
            started_r = 1'b0;
            
        end
        
    end
    
endmodule
