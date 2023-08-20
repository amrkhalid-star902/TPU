`timescale 1ns / 1ps

module master_control(
    
     clk,
     reset,
     reset_out,
     start,
     done,
     opcode,
     dim_1,
     dim_2,
     dim_3,
     addr_1,
     accum_table_submatrix_row_in,
     accum_table_submatrix_col_in,
     weight_fifo_done,
     data_mem_done,
     fifo_ready,
     bus_to_mem_addr,
     input_mem_wr_en,
     weight_mem_out_rd_addr,
     weight_mem_out_rd_en,
     weight_mem_wr_en,
     output_mem_wr_addr,
     output_mem_wr_en,
     output_mem_rd_en,
     in_fifo_active,
     out_fifo_active,
     data_mem_en,
     wr_submatrix_row_out,
     wr_submatrix_col_out,
     wr_row_num,
     rd_submatrix_row_out,
     rd_submatrix_col_out,
     rd_row_num,
     accum_clear,
     relu_en
         
);

    parameter MAX_OUT_ROWS = 128; 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    parameter ADDR_WIDTH = 8;
    
    localparam NUM_SUBMATS_M  = MAX_OUT_ROWS/SYS_ARR_ROWS; 
    localparam NUM_SUBMATS_N  = MAX_OUT_COLS/SYS_ARR_COLS;  
    
    //Instructions opcode
    parameter READ_INPUTS     = 3'b001;
    parameter READ_WEIGHTS   = 3'b010;
    parameter FILL_FIFO       = 3'b011;
    parameter MATRIX_MULTIPLY = 3'b100;
    parameter STORE_OUTPUTS   = 3'b101;
    parameter READ_OUTPUTS   = 3'b110;
    parameter INIT_TPU        = 3'b111;
    
    input clk , reset;
    output reg reset_out;  //Universal reset signal to all modules in TPU
    
    input start;           //Pulse signal to start the excution of the instructions.
    output reg done;            //Indicate that the control unit is ready to handle new instruction.
    
    
    //Instruction set input
    input [2:0] opcode;
    input [$clog2(SYS_ARR_ROWS)-1 : 0] dim_1 , dim_2 , dim_3;
    input [ADDR_WIDTH-1 : 0]addr_1;
    input [$clog2(NUM_SUBMATS_M)-1 : 0] accum_table_submatrix_row_in;
    input [$clog2(NUM_SUBMATS_N)-1 : 0] accum_table_submatrix_col_in;
    
    
    //Inputs ports that used in matrix multplication
    input weight_fifo_done;
    input data_mem_done;
    
    //This output signal tell the cpu when fifo is ready to be filled again
    output fifo_ready;
    
    //The write address for the following memory modules : InputMemory , WeightMemory , OutputMemory
    output [SYS_ARR_COLS*ADDR_WIDTH-1 : 0] bus_to_mem_addr;
    
    //write control of input memory
    output reg [SYS_ARR_COLS-1 : 0] input_mem_wr_en;
    
    //Output signals to control weight memory
    output [SYS_ARR_COLS*ADDR_WIDTH-1 : 0] weight_mem_out_rd_addr;
    output [SYS_ARR_COLS-1 : 0] weight_mem_out_rd_en;
    output reg [SYS_ARR_COLS-1 : 0] weight_mem_wr_en;
     
     
     //Output signals to control output memory
     output [SYS_ARR_COLS*ADDR_WIDTH-1 : 0] output_mem_wr_addr;
     output [SYS_ARR_COLS-1 : 0] output_mem_wr_en;
     output reg [SYS_ARR_COLS-1 : 0] output_mem_rd_en;
     
     
     //Output signal to control filling the FIFO with input
     output in_fifo_active;
     
     //Output signal to control reading data from the FIFO
     output out_fifo_active;
     
     //Output signal to control reading of the inputs from the memory
     output data_mem_en;
     
     //Output signals that control writing to the accumlator table
     output [$clog2(NUM_SUBMATS_M)-1 : 0] wr_submatrix_row_out;
     output [$clog2(NUM_SUBMATS_N)-1 : 0] wr_submatrix_col_out;
     output [$clog2(SYS_ARR_ROWS)-1 : 0] wr_row_num;
     
     
     //Output signals that control reading from the accumlator table
     output [$clog2(NUM_SUBMATS_M)-1 : 0] rd_submatrix_row_out;
     output [$clog2(NUM_SUBMATS_N)-1 : 0] rd_submatrix_col_out;
     output [$clog2(SYS_ARR_ROWS)-1 : 0] rd_row_num;
     
     output accum_clear , relu_en;
     
     
     //Some signals declartion for start and done putputd
     reg start_mem_control;
     reg start_fill_fifo_control;
     reg start_multip_control;
     reg start_output_control;
     reg start_reset_control;
     
     wire done_mem_contol;
     wire done_fill_fifo_control;
     wire done_multip_control;
     wire done_output_control;     
     reg done_reset_control;
     
     wire [SYS_ARR_COLS-1 : 0] mem_control_en;
     
     
     master_mem_ctrl  master_mem_ctrl(
         
         .clk(clk),
         .reset(reset | reset_out),
         .active(start_mem_control),
         .base_addr(addr_1),
         .rows_enabled_num(dim_1),
         .cols_enabled_num(dim_2),
         .out_addr(bus_to_mem_addr),
         .out_en(mem_control_en),
         .done(done_mem_contol)
         
     );
     
     
     Fill_FIFO_Ctrl fill_fifo_ctrl(
         
         .clk(clk),
         .reset(reset | reset_out),
         .start(start_fill_fifo_control),
         .done(done_fill_fifo_control),
         .rows_enabled_num(dim_1),
         .cols_enabled_num(dim_2),
         .base_addr(addr_1),
         .weightMem_rd_en(weight_mem_out_rd_en),
         .weightMem_rd_addr(weight_mem_out_rd_addr),
         .fifo_active(in_fifo_active)
         
     );
     
     
     master_multiply_ctrl master_multiply_ctrl(
        
        .clk(clk),
        .reset(reset | reset_out),
        .active(start_multip_control),
        .intermed_dim(dim_1),
        .weight_matrix_row_num(dim_2),
        .input_matrix_col_num(dim_3),
        .base_addr(addr_1),
        .accum_table_submatrix_row_in(accum_table_submatrix_row_in),
        .accum_table_submatrix_col_in(accum_table_submatrix_col_in),
        .accum_table_submatrix_row_out(wr_submatrix_row_out),
        .accum_table_submatrix_col_out(wr_submatrix_col_out),
        .weight_fifo_enable(out_fifo_active),
        .weight_fifo_done(weight_fifo_done),
        .input_mem_enable(data_mem_en),
        .input_mem_done(data_mem_done),
        .fifo_ready(fifo_ready),
        .done(done_multip_control)
        
     );
    
     
     master_output_ctrl master_output_ctrl(
         
         .clk(clk),
         .start(reset | reset_out),
         .reset(start_output_control),
         .submatrix_row_in(accum_table_submatrix_row_in),
         .submatrix_col_in(accum_table_submatrix_col_in),
         .submatrix_row_out(rd_submatrix_row_out),
         .submatrix_col_out(rd_submatrix_col_out),
         .read_rows_num(dim_1),
         .read_cols_num(dim_2),
         .row_num(rd_row_num),
         .clear_after(dim_3[1]),
         .activate(dim_3[0]),
         .accum_clear(accum_clear),
         .relu_en(relu_en),
         .wr_base_addr(addr_1),
         .wr_en(output_mem_wr_en),
         .wr_addr(output_mem_wr_addr),
         .done(done_output_control)
         
     );

    always@(*)
    begin
        
        input_mem_wr_en      = {SYS_ARR_COLS{1'b0}};
        weight_mem_wr_en = {SYS_ARR_COLS{1'b0}};
        output_mem_rd_en     = {SYS_ARR_COLS{1'b0}};
        
        start_mem_control = 1'b0;
        start_fill_fifo_control = 1'b0;
        start_multip_control = 1'b0;
        start_output_control = 1'b0;
        start_reset_control = 1'b0;
        done = 1'b1;   
        
        case(opcode)
            
            READ_INPUTS:
            begin
            
                start_mem_control = start;    
                done              = done_mem_contol;
                input_mem_wr_en   = mem_control_en;
                
            end
            
            READ_WEIGHTS:
            begin
            
                 start_mem_control = start;   
                 done              = done_mem_contol;
                 weight_mem_wr_en  = mem_control_en;
                 
            end
            
            FILL_FIFO:
            begin
            
                start_fill_fifo_control = start;
                done                    = done_fill_fifo_control;
                
            end
            
            MATRIX_MULTIPLY:
            begin
                
                start_multip_control  = start;
                done                  = done_multip_control;
            
            end
            
            STORE_OUTPUTS:
            begin
            
                start_output_control  = start;
                done                  = done_output_control;
            
            end
            
            READ_OUTPUTS:
            begin
            
                start_mem_control = start;
                done              = done_mem_contol;
                output_mem_rd_en  = mem_control_en;
            
            end
            
            INIT_TPU:
            begin
                
                start_reset_control  = start;
                done                 = done_reset_control;
            
            end
        
        endcase
    
    end
     
    
    always @(posedge clk) begin
        if (start_reset_control) begin
        
            reset_out = 1'b1;
            done_reset_control = 1'b0;
            
        end 

        else begin
        
            reset_out = 1'b0;
            done_reset_control = 1'b1;
            
        end 
        
    end 
    
        
endmodule
