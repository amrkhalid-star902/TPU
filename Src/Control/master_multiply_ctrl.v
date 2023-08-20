`timescale 1ns / 1ps



module master_multiply_ctrl(
    
    clk,
    reset,
    active,
    intermed_dim,
    weight_matrix_row_num,
    input_matrix_col_num,
    base_addr,
    accum_table_submatrix_row_in,
    accum_table_submatrix_col_in,
    accum_table_submatrix_row_out,
    accum_table_submatrix_col_out,
    weight_fifo_enable,
    weight_fifo_done,
    input_mem_enable,
    input_mem_done,
    fifo_ready,
    done
    
);

    parameter  WIDTH_HEIGHT     = 16;
    parameter  ADDR_WIDTH       = WIDTH_HEIGHT * 8;
    parameter  WIDTH_HEIGHT_OUT = 128;
    parameter  MAT_NUM          = WIDTH_HEIGHT_OUT / WIDTH_HEIGHT;
    
    parameter  HOLD       = 2'b00;
    parameter  FIFO_CTRL  = 2'b01;
    parameter  MEM_CTRL   = 2'b10;
    
    input clk, reset, active;
    input weight_fifo_done , input_mem_done;
    input [$clog2(WIDTH_HEIGHT)-1 : 0] intermed_dim , weight_matrix_row_num , input_matrix_col_num;
    input [ADDR_WIDTH-1 : 0] base_addr;
    input [$clog2(MAT_NUM)-1 : 0] accum_table_submatrix_row_in;
    input [$clog2(MAT_NUM)-1 : 0] accum_table_submatrix_col_in;
    
    output [$clog2(MAT_NUM)-1 : 0] accum_table_submatrix_row_out;
    output [$clog2(MAT_NUM)-1 : 0] accum_table_submatrix_col_out;
    output reg weight_fifo_enable , input_mem_enable;
    output fifo_ready , done;
    
    reg [1:0] state , state_r;
    
    assign accum_table_submatrix_row_out = accum_table_submatrix_row_in;
    assign accum_table_submatrix_col_out = accum_table_submatrix_col_in;
    assign fifo_ready = weight_fifo_done;
    assign done = (state == HOLD) ? 1'b1 : 1'b0;
    
    always@(posedge clk)
    begin
        
        state <= state_r;
    
    end
    
    always@(*)
    begin
    
        case(state)
            
            HOLD: begin
            
                input_mem_enable    = 1'b0;
                weight_fifo_enable  = 1'b0;
                
                if(active)
                begin
                    
                    state_r = FIFO_CTRL;
                    weight_fifo_enable = 1'b1;
                    
                end
            
            end
            
            FIFO_CTRL: begin
            
                input_mem_enable    = 1'b0;
                weight_fifo_enable  = 1'b0;    
                
                //Wait until the enable signals of  fifo is set.
                if(weight_fifo_done)
                begin
                    
                    state_r = MEM_CTRL;
                
                end
                
            
            end
            
            MEM_CTRL: begin
            
                input_mem_enable    = 1'b1;
                weight_fifo_enable  = 1'b0; 
                
                //Wait until the operation of input memory (read or write) is done
                if(input_mem_done)
                begin
                    
                    state_r = HOLD;
                
                end            
            
            end
            
        endcase
        
        if(reset)
        begin
        
            state_r = HOLD;
            input_mem_enable    = 1'b0;
            weight_fifo_enable  = 1'b0; 
            
        end
    
    end
    
endmodule
