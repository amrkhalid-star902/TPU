`timescale 1ns / 1ps


module master_mem_ctrl(
    
    clk,
    reset,
    active,
    base_addr,
    rows_enabled_num,
    cols_enabled_num,
    out_addr,
    out_en,
    done
    
);
    
    parameter  ADDR_WIDTH     = 8;
    parameter  WIDTH_HEIGHT   = 16;
    localparam ADDR_OUT_WIDTH = ADDR_WIDTH * WIDTH_HEIGHT;
    
    input clk , reset , active;
    input [ADDR_WIDTH-1 : 0] base_addr;
    input [$clog2(WIDTH_HEIGHT)-1 : 0] rows_enabled_num , cols_enabled_num;
    
    output reg done;
    output wire [ADDR_WIDTH-1 : 0] out_en;
    output wire  [ADDR_OUT_WIDTH-1 : 0] out_addr;
    
    reg start , start_r , done_r;
    reg [$clog2(WIDTH_HEIGHT)-1 : 0] count , count_r;
    
    assign out_en = {WIDTH_HEIGHT{start}};
    assign out_addr = {WIDTH_HEIGHT{base_addr + count}};
    
    always@(posedge clk)
    begin
        
        count <= count_r;
        start <= start_r;
        done  <= done_r;
        
    end
    
    
    always@(*)
    begin
        
        if(active)
        begin
        
            start_r = 1'b1;
            done_r  = 0;
        
        end
        
        if(start)
        begin
        
            
            count_r  = count + 1;
            
            if(count >= rows_enabled_num)
            begin
                
                count_r = 0;
                done_r  = 1;
                start_r = 0;
            
            end
        
        end
        
        if(reset)
        begin
            
            count_r = 0;
            done_r  = 0;
            start_r = 0;
        
        end
    
    end

endmodule
