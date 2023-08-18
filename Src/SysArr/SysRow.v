`timescale 1ns / 1ps

module SysRow(
    
    clk,
    active,
    data_in,
    w_in,
    sum_in,
    weight_wren,
    mac_out,
    w_out,
    weight_wren_out,
    active_out,
    data_out
    
);


    parameter   row_width = 2;
    localparam  weight_width = 8  * row_width;   //Each PE in the row needs 8 bits to represent the input weight
    localparam  sum_width    = 16 * row_width;   //Each PE needs 16 bits to represent the input sum fields
    
    input clk;
    input active; 
    input signed [7:0]  data_in;             // Each row needs 8 bit input data
    input signed [weight_width-1:0] w_in;    //8 bits for each PE. Left most PE has LSB
    input signed [sum_width-1:0]    sum_in;  // 16 bits for each PE. Left most PE has LSB
    input        [row_width-1 : 0]  weight_wren;
    
    
    output signed [sum_width-1:0] mac_out;
    output signed [weight_width-1:0] w_out;
    output        [row_width-1:0] weight_wren_out;
    output        [row_width-1:0] active_out;
    output signed [7:0] data_out;             // Outputs to the right side of the array
    
    
    //Intraconnections within the sysrow (PE -> PE)
    wire         [row_width-1:0]  active_temp;
    wire signed  [(weight_width-8)-1 : 0] data_temp;    
    
    assign active_out = active_temp;
    
    genvar i;
    generate
        
        for(i = 0 ; i < row_width ; i = i + 1)
        begin : generate_PE
        
            if(i == 0)
            begin
            
                PE first_pe(
                 
                   .clk(clk),
                   .active(active),
                   .data_in(data_in),
                   .w_in(w_in[7:0]),
                   .sum_in(sum_in[15:0]),
                   .weight_wren(weight_wren[0]),
                   
                   .mac_out(mac_out[15:0]),
                   .data_out(data_temp[7:0]),
                   .weight_out(w_out[7:0]),
                   .weight_wren_out(weight_wren_out[0]),
                   .active_out(active_temp[0])
                   
                 );
            
            end
            
            else if(i == row_width - 1)
            begin
            
               PE last_pe(
             
                   .clk(clk),
                   .active(active_temp[i - 1]),
                   .data_in(data_temp[(i*8)-1:(i-1)*8]),
                   .w_in(w_in[((i+1)*8)-1:(i*8)]),
                   .sum_in(sum_in[((i+1)*16)-1:(i*16)]),
                   .weight_wren(weight_wren[i]),
                   
                   .mac_out(mac_out[((i+1)*16)-1:(i*16)]),
                   .data_out(data_out),
                   .weight_out(w_out[((i+1)*8)-1:(i*8)]),
                   .weight_wren_out(weight_wren_out[i]),
                   .active_out(active_temp[i])
               
             );
                
            
            end
            
            else begin
            
               PE normal_pe(
          
                   .clk(clk),
                   .active(active_temp[i - 1]),
                   .data_in(data_temp[(i*8)-1:(i-1)*8]),
                   .w_in(w_in[((i+1)*8)-1:(i*8)]),
                   .sum_in(sum_in[((i+1)*16)-1:(i*16)]),
                   .weight_wren(weight_wren[i]),
                    
                   .mac_out(mac_out[((i+1)*16)-1:(i*16)]),
                   .data_out(data_temp[((i+1)*8)-1:(i*8)]),
                   .weight_out(w_out[((i+1)*8)-1:(i*8)]),
                   .weight_wren_out(weight_wren_out[i]),
                   .active_out(active_temp[i])
            
             );           
               
            
            
            end
        
        end
        
    endgenerate
    
    
endmodule
