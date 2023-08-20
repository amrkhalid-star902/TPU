`timescale 1ns / 1ps



module Fill_FIFO_Ctrl(
    
    clk,
    reset,
    start,
    done,
    rows_enabled_num,
    cols_enabled_num,
    base_addr,
    weightMem_rd_en,
    weightMem_rd_addr,
    fifo_active
    
);
    
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    parameter ADDR_WIDTH = 8;   
    
    input clk;
    input reset;
    input start;
    output wire done;
    input [$clog2(SYS_ARR_ROWS)-1 : 0] rows_enabled_num;
    input [$clog2(SYS_ARR_ROWS)-1 : 0] cols_enabled_num;
    input [ADDR_WIDTH-1 : 0] base_addr;
    output reg [SYS_ARR_COLS-1:0] weightMem_rd_en;
    output wire [SYS_ARR_COLS*ADDR_WIDTH-1:0] weightMem_rd_addr;
    output reg fifo_active;
    
    
    reg started , started_r;
    
    reg [$clog2(SYS_ARR_ROWS) : 0] count , count_r;
    
    assign done = ~started;
    assign weightMem_rd_addr = {SYS_ARR_COLS{base_addr + count}};
    
    
    always@(posedge clk)
    begin
    
        started <= started_r;
        count   <= count_r;
    
    end
    
    always@(*)
    begin
    
        started_r   = started;
        count_r     = count;
        weightMem_rd_en = {SYS_ARR_COLS{1'b0}};
        fifo_active = 1'b0;
        
        if(start)
        begin
            
            started_r = 1'b1;
        
        end
        
        if(started)
        begin
        
            count_r = count + 1;
            
            if(count < cols_enabled_num + 1)
            begin
                
                weightMem_rd_en = {SYS_ARR_COLS{1'b1}} >> (SYS_ARR_COLS - rows_enabled_num - 1);
            
            end
            
            if(count == 1)
            begin
            
                fifo_active = 1'b1;
            
            end
            
            if(count == SYS_ARR_ROWS + 1)
            begin
            
                started_r   = 0;
                count_r     = 0;
            
            end 
        
        end
        
        if(reset)
        begin
            
            started_r   = 0;
            count_r     = 0;        
        
        end
    
    end
    
    
endmodule
