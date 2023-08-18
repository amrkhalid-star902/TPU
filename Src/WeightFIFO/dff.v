`timescale 1ns / 1ps


module dff(clk , reset , en , d , q);

    parameter DATA_WIDTH = 8;

    input clk;
    input reset;
    input en;
    input signed [DATA_WIDTH-1:0] d;
    output reg signed [DATA_WIDTH-1:0] q;
    
    
    always@(posedge clk)
    begin
    
        if(reset)
        begin
        
            q <= 0;
        
        end
        
        else if(en)
        begin
            
            q <= d;
            
        end
        
        else
        begin
        
            q <= q;
        
        end
    
    end
    
endmodule
