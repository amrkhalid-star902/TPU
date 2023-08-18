`timescale 1ns / 1ps



module AccumTableAddreCtrl(
    
    sub_row,
    submat_row_idx,
    submat_col_idx,
    addr
        
);


    parameter MAX_OUT_ROWS = 128;
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    
    localparam NUM_ACCUM_ROWS  = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_ROW_SUB_MAT = MAX_OUT_ROWS / SYS_ARR_ROWS;                         //Number of sub matrices present in one row
    localparam NUM_COL_SUB_MAT = MAX_OUT_COLS / SYS_ARR_COLS;                         //Number of sub matrices present in one column
    
    
    input [$clog2(SYS_ARR_ROWS)-1 : 0]    sub_row;
    input [$clog2(NUM_ROW_SUB_MAT)-1 : 0] submat_row_idx;
    input [$clog2(NUM_COL_SUB_MAT)-1 : 0] submat_col_idx;
    output [$clog2(NUM_ACCUM_ROWS)-1 : 0]  addr;
    
    
    assign addr = (submat_col_idx*MAX_OUT_ROWS) + (submat_row_idx*SYS_ARR_ROWS) + (SYS_ARR_ROWS-1-sub_row);

endmodule
