`timescale 1ns / 1ps


module AccumTableWrCtrl(
    
    clk,
    reset,
    wr_en_in,
    sub_row,
    submat_row_idx,
    submat_col_idx,
    wr_en_out,
    wr_addr_out
    
);

    parameter MAX_OUT_ROWS = 128;
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    
    localparam NUM_ACCUM_ROWS  = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_ROW_SUB_MAT = MAX_OUT_ROWS / SYS_ARR_ROWS;                         //Number of sub matrices present in one row
    localparam NUM_COL_SUB_MAT = MAX_OUT_COLS / SYS_ARR_COLS; 
    localparam ADDR_WIDTH      = $clog2(NUM_ACCUM_ROWS);  
    
    
    input clk;
    input reset;
    input wr_en_in;
    input [$clog2(SYS_ARR_ROWS)-1 : 0] sub_row;
    input [$clog2(NUM_ROW_SUB_MAT)-1 : 0] submat_row_idx;
    input [$clog2(NUM_COL_SUB_MAT)-1 : 0] submat_col_idx;
    output wire [SYS_ARR_COLS-1:0] wr_en_out;
    output wire [ADDR_WIDTH*SYS_ARR_COLS-1:0] wr_addr_out;    
    
    
    wire [ADDR_WIDTH-1:0] addr0;
    reg [SYS_ARR_COLS-1:0] wr_en_out_partial, wr_en_out_partial_c;
    reg [ADDR_WIDTH*(SYS_ARR_COLS)-1:0] wr_addr_out_partial, wr_addr_out_partial_c;
    
    AccumTableAddreCtrl accumlateTable(
       
       .sub_row(sub_row),
       .submat_row_idx(submat_row_idx),
       .submat_col_idx(submat_col_idx),
       .addr(addr0)
           
    );
    
    assign wr_en_out = wr_en_out_partial;
    assign wr_addr_out = wr_addr_out_partial;
    
    always@(clk , reset , wr_en_in , sub_row , submat_row_idx , submat_row_idx)
    begin
        
        wr_en_out_partial_c[0] = wr_en_in;
        wr_addr_out_partial_c[ADDR_WIDTH-1:0] = addr0;
        
        wr_en_out_partial_c[SYS_ARR_COLS-1:1] = wr_en_out_partial[SYS_ARR_COLS-2:0];
        wr_addr_out_partial_c[ADDR_WIDTH*(SYS_ARR_COLS)-1:ADDR_WIDTH] = wr_addr_out_partial[ADDR_WIDTH*(SYS_ARR_COLS-1)-1:0]; 
        
        if(reset)
        begin
            
            wr_en_out_partial_c = 15'h0;
        
        end 
    
    
    end
    
    always @(posedge clk) begin
        wr_en_out_partial <= wr_en_out_partial_c;
        wr_addr_out_partial <= wr_addr_out_partial_c;
    end // always @(posedge clk)
    
    



endmodule
