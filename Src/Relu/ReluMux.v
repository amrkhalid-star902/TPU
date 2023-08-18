`timescale 1ns / 1ps

module ReluMux(en , In , Out);

    parameter DATA_WIDTH = 16;
    
    input  en;
    input  signed[DATA_WIDTH-1:0] In;
    output signed[DATA_WIDTH-1:0] Out;
    
    assign Out = (In > 0 || en) ? In : 0;

endmodule
