`timescale 1ns / 1ps

//Prccessing element

module PE(
    
    clk,
    active,
    data_in,
    w_in,
    sum_in,
    weight_wren,
    
    mac_out,
    data_out,
    weight_out,
    weight_wren_out,
    active_out
    
);

    
    input clk;
    input active;                                 //a signal that indicates whether the systolic array should be actively performing multiplies and passing values.
    input signed [7:0]  data_in;                  //an 8-bit input representing a matrix element that is multiplied by the weight.
    input signed [7:0]  w_in;                     //an 8-bit input representing the weight value.
    input signed [15:0] sum_in;                   //a 16-bit input representing the sum input from the previous element in the systolic array.
    input weight_wren;                            //a control signal that determines whether the internal weight should be updated.
    
    output reg signed [15:0] mac_out;                 //a 16-bit output representing the result of the multiply-and-accumulate operation (datain * weight + sumin).
    output reg signed [7:0]  data_out;                //an 8-bit output that passes the datain value to the right, to the next processing element in the systolic array.
    output reg signed [7:0]  weight_out;              //an 8-bit output representing the weight value that is passed to the right, to the next processing element in the systolic array.
    output reg weight_wren_out;                       //a control signal that determines whether the next processing element should update its internal weight.
    output reg active_out;                            //a signal indicating whether the systolic array should be actively performing multiplies and passing values.
    
    reg signed [15:0] mac_out_r;
    reg signed [7:0]  data_out_r , weight_out_r;
    reg signed [7:0]  weight , weight_r;
    reg weight_wren_out_r , active_out_r;
    
    wire [15:0] product;
    
     Multiplier mult(
         .a(data_in),
         .b(weight),
         .product(product)
     );
     
     always@(*)
     begin
     
        active_out_r = active;
        if(active == 1'b1)
        begin
            
            data_out_r = data_in;
            mac_out_r  = sum_in + product;
        
        end
        
        else
        begin
            
            //Stall
             data_out_r = data_out;
             mac_out    = mac_out;
        
        end
        
        
     end     
     
     
     always@(*)
     begin
     
        weight_wren_out_r = weight_wren;
        
        if((weight_wren == 1'b1) || (weight_wren_out == 1'b1)) 
        begin
            
            weight_r       = w_in;
            weight_out_r   = weight;
        
        end
        
        else
        begin
            
            weight_r       = weight;
            weight_out_r   = 8'hAA;
        
        end
     
     end
     
     
     always@(posedge clk)
     begin
     
        mac_out           <= mac_out_r;
        data_out          <= data_out_r;
        weight            <= weight_r; 
        weight_out        <= weight_out_r; 
        weight_wren_out   <= weight_wren_out_r;
        active_out        <= active_out_r;
     
     end
     

endmodule
