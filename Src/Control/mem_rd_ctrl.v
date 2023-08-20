`timescale 1ns / 1ps


module mem_rd_ctrl(
    
    clk,
    reset,
    active,
    rd_en,
    rd_addr,
    wr_active      //Enable write output control
    
);

    parameter  WIDTH_HEIGHT = 16;
    localparam DATA_WIDTH   = WIDTH_HEIGHT * 8;
    localparam COUNT_WIDTH  = $clog2(WIDTH_HEIGHT) + 1;
    
    input clk;
    input reset;
    input active;
    output reg [WIDTH_HEIGHT-1 : 0] rd_en;
    output reg [DATA_WIDTH-1 : 0] rd_addr;
    output reg wr_active;
    
    
    //Using double latching techniques to prevent race conditions and unexpected behaviour of the code
    reg [WIDTH_HEIGHT-1 : 0] rd_en_r;
    reg [DATA_WIDTH-1 : 0] rd_addr_r;
    reg [COUNT_WIDTH-1 : 0] count , count_r;
    reg rd_start , rd_start_r;
    
    always@(posedge clk)
    begin
    
        rd_en    <= rd_en_r;
        rd_addr  <= rd_addr_r;
        count    <= count_r;
        rd_start <= rd_start_r;
    
    end
    
    always@(*)
    begin
    
        rd_addr_r  = rd_addr;
        count_r    = count;
        rd_start_r = rd_start;
        wr_active  = 0;
        
        
        if(active)
        begin
            
            rd_start_r = 1'b1;
        
        end
        
        if(rd_start)
        begin
            
            if(count >= 16 )
            begin
                
                rd_en_r = rd_en << 1;
            
            end
            
            else begin
                
                rd_en_r = (rd_en << 1) + 1'b1;
            
            end
            
            rd_addr_r =  {7'b0, rd_en[15],
                          7'b0, rd_en[14],
                          7'b0, rd_en[13],
                          7'b0, rd_en[12],
                          7'b0, rd_en[11],
                          7'b0, rd_en[10],
                          7'b0, rd_en[9],
                          7'b0, rd_en[8],
                          7'b0, rd_en[7],
                          7'b0, rd_en[6],
                          7'b0, rd_en[5],
                          7'b0, rd_en[4],
                          7'b0, rd_en[3],
                          7'b0, rd_en[2],
                          7'b0, rd_en[1],
                          7'b0, rd_en[0]} + rd_addr;
                          
                          
             count_r = count + 1'b1;
             
             if(count > 16)
             begin
                
                wr_active = 1'b1;
             
             end
             
             if(count == WIDTH_HEIGHT*2 - 1)
             begin
                
                rd_start_r = 1'b0;
                rd_addr_r  = 16'h0000;
                count_r    = 0;
                wr_active  = 0;   
                
             end
            
        end
        
        else begin
            
            rd_en_r = 16'h0000;
        
        end
        
        if(reset == 1'b1)
        begin
            
            rd_addr_r  = 0;
            rd_en_r    = 16'h0000;
            rd_start_r = 1'b0; 
            count_r    = 0;
            wr_active  = 0;
        end
        
    end

endmodule
