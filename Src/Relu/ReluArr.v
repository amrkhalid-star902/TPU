`timescale 1ns / 1ps


module ReluArr(en , In , Out);
    
    parameter DATA_WIDTH = 16;
    parameter ARR_INPUTS = 16;
    
    localparam ARR_WIDTH = DATA_WIDTH*ARR_INPUTS;
    
    input  en;
    input  signed[ARR_WIDTH-1:0] In;
    output signed[ARR_WIDTH-1:0] Out;
    
    ReluMux MuxArr[ARR_INPUTS-1:0](.en(en) , .In(In) , .Out(Out));
    
endmodule
