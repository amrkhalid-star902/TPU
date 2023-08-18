`timescale 1ns / 1ps

module SysArray(
    
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

    parameter   rows_num = 4;
    localparam  weight_width = 8  * rows_num;   
    localparam  sum_width    = 16 * rows_num;
    localparam  data_width   = 8  * rows_num;
    
    input clk;
    input active; 
    input signed [data_width-1:0]   data_in;    // 8 bits of data is needed for every row. LSB represent the data of the top row.
    input signed [weight_width-1:0] w_in;       //8 bits for each PE. Left most PE has LSB.
    input signed [sum_width-1:0]    sum_in;     // 16 bits for each PE. Left most PE has LSB. In most cases it is equal to zero.
    input        [rows_num-1 : 0]  weight_wren; //1 activation bit for each PE . the LSB represent the most left PE.
    
    output signed [sum_width-1:0] mac_out;
    output signed [weight_width-1:0] w_out;
    output        [rows_num-1:0] weight_wren_out;
    output        [rows_num-1:0] active_out;
    output signed [data_width-1:0] data_out;    //Each row has 8 bits
    
    
    //Intraconnections within the systollic array (row --> row)
    //A 1 is subtracted from the rows_num because the last row accumulative output is connected directly to the output port and doesnt need intermediate holders.
    wire [((rows_num-1)*rows_num*16)-1:0] maccout_temp;    
    wire [((rows_num-1)*rows_num*8)-1:0]  wout_temp;
    wire [((rows_num-1)*rows_num)-1:0]    weight_wren_temp;
    wire [((rows_num-1)*rows_num)-1:0]    active_out_temp;
    
    
    genvar i;
    generate
    
        for(i = 0 ; i < rows_num ; i = i + 1) begin : genSysRow
        
            if(i == 0) 
            begin
            
                SysRow first_row(
                
                    .clk(clk),
                    .active(active),
                    .data_in(data_in[((i+1)*8)-1:(i*8)]),
                    .w_in(w_in),
                    .sum_in(sum_in),
                    .weight_wren(weight_wren),
                    .mac_out( maccout_temp[((i+1)*rows_num*16)-1:(i*rows_num*16)]),
                    .w_out(wout_temp[((i+1)*rows_num*8)-1:(i*rows_num*8)]),
                    .weight_wren_out(weight_wren_temp[((i+1)*rows_num)-1:(i*rows_num)]),
                    .active_out(active_out_temp[((i+1)*rows_num)-1:(i*rows_num)]),
                    .data_out(data_out[((i+1)*8)-1 : (i*8)])
                
                );
                
                defparam first_row.row_width = rows_num;
            
            end
            
            else if(i == rows_num - 1)
            begin
            
                SysRow last_row(
            
                    .clk(clk),
                    .active(active_out_temp[((i-1)*rows_num)]),
                    .data_in(data_in[((i+1)*8)-1:(i*8)]),
                    .w_in(wout_temp[(i*rows_num*8)-1:((i-1)*rows_num*8)]),
                    .sum_in( maccout_temp[(i*rows_num*16)-1:((i-1)*rows_num*16)]),
                    .weight_wren(weight_wren_temp[(i*rows_num)-1 : ((i-1)*rows_num)]),
                    .mac_out( mac_out),
                    .w_out(w_out),
                    .weight_wren_out(weight_wren_out),
                    .active_out(active_out),
                    .data_out(data_out[((i+1)*8)-1 : (i*8)])
            
                ); 
                
                defparam last_row.row_width = rows_num;
            
            
            
            end
            
            else
            begin
            
                SysRow normal_row(
        
                    .clk(clk),
                    .active(active_out_temp[((i-1)*rows_num)]),
                    .data_in(data_in[((i+1)*8)-1:(i*8)]),
                    .w_in(wout_temp[(i*rows_num*8)-1:((i-1)*rows_num*8)]),
                    .sum_in( maccout_temp[(i*rows_num*16)-1:((i-1)*rows_num*16)]),
                    .weight_wren(weight_wren_temp[(i*rows_num)-1 : ((i-1)*rows_num)]),
                    .mac_out( maccout_temp[((i+1)*rows_num*16)-1:(i*rows_num*16)]),
                    .w_out(wout_temp[((i+1)*rows_num*8)-1:(i*rows_num*8)]),
                    .weight_wren_out(weight_wren_temp[((i+1)*rows_num)-1:(i*rows_num)]),
                    .active_out(active_out_temp[((i+1)*rows_num)-1:(i*rows_num)]),
                    .data_out(data_out[((i+1)*8)-1 : (i*8)])
        
               ); 
               
               defparam normal_row.row_width = rows_num;
            
            
            end
        
        end
            
    
    endgenerate

endmodule
