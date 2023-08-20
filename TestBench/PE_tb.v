`timescale 1ns / 1ps


module PE_tb();


    reg clk, active, wwrite;
    reg [7:0] datain, win;
    reg [15:0] sumin;

    wire [15:0] maccout;
    wire [7:0] dataout, wout;
    wire wwriteout, activeout;

    integer i;
    
     PE DUT(
     
       .clk(clk),
       .active(active),
       .data_in(datain),
       .w_in(win),
       .sum_in(sumin),
       .weight_wren(wwrite),
       
       .mac_out(maccout),
       .data_out(dataout),
       .weight_out(wout),
       .weight_wren_out(wwriteout),
       .active_out(activeout)
       
     );
     
     
    always begin
    
        #5;
        clk = ~clk;
        
    end

    initial begin
    
        clk = 1'b0;
        active = 1'b1;
        wwrite = 1'b0;
        datain = 8'h00;
        win = 8'h00;
        sumin = 16'h0000;
    
        #100;
    
        wwrite = 1'b1;
    
        for (i = 0; i < 64; i = i + 1) begin
            #10;
            win = win + 8'h04;
            datain = datain + 8'h0A;
        end
    
        wwrite = 1'b0;
    
        for (i = 0; i < 64; i = i + 1) begin
            #10;
            win = win + 8'h02;
        end
        
    end
    
    
endmodule
