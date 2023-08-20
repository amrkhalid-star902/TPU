`timescale 1ns / 1ps


module input_mem (

  input clock,
  input [7:0] data,
  input [7:0] rdaddress,
  input rden,
  input [7:0] wraddress,
  input wren,
  output reg [7:0] q
  
);

  reg [7:0] memory [0:15];

  always @(posedge clock) begin
    if (rden)
    
      q <= memory[rdaddress];
      
    if (wren)
    
      memory[wraddress] <= data;
      
  end

endmodule