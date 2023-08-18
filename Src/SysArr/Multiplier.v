`timescale 1ns / 1ps

module Multiplier(

    input  signed [7:0]  a,
    input  signed [7:0]  b,
    output signed [15:0] product
    
);

    assign product = a * b;
    
endmodule
