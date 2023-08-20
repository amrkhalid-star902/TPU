`timescale 1ns / 1ps


module TPU(
    
    clk,
    reset,
    start,
    done,
    opcode,
    dim_1,
    dim_2,
    dim_3,
    addr_1,
    accum_table_submatrix_row_in,    // The row index of the submatrix 
    accum_table_submatrix_col_in,    // The coloumn index of the submatrix
    fifo_ready,
    inputMem_wr_data,
    weightMem_wr_data,
    outputMem_rd_data
    
);
    
    parameter WIDTH_HEIGHT = 16;
    parameter DATA_WIDTH   = 8;
    parameter MAX_MAT_DIM  = 128;
    parameter ADDR_WIDTH   = 7;
    parameter NUM_ACCUM_ROWS = MAX_MAT_DIM * (MAX_MAT_DIM/WIDTH_HEIGHT);
    
    
    //-----------------Input Ports--------------------------//
    
    input clk , start , reset;
    input [2:0] opcode;
    input [$clog2(WIDTH_HEIGHT)-1 : 0] dim_1;
    input [$clog2(WIDTH_HEIGHT)-1 : 0] dim_2;
    input [$clog2(WIDTH_HEIGHT)-1 : 0] dim_3;
    input [ADDR_WIDTH-1 : 0]           addr_1;
    input [$clog2(MAX_MAT_DIM/WIDTH_HEIGHT)-1 : 0] accum_table_submatrix_row_in;
    input [$clog2(MAX_MAT_DIM/WIDTH_HEIGHT)-1 : 0] accum_table_submatrix_col_in;
    input [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] inputMem_wr_data;
    input [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] weightMem_wr_data;
    
    
    //-----------------Output Ports--------------------------//
    
    output done;
    output fifo_ready;
    output [2*WIDTH_HEIGHT*DATA_WIDTH-1 : 0] outputMem_rd_data;   //The width of the data produced from the multiply and accumulate operation is 16 bits double the width of weights and data inputs
    
    
    //-----------------Some local wires and regs declartions--------------------------//
    
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] inputMem_to_sysArr;
    wire [WIDTH_HEIGHT-1 : 0] inputMem_rd_en;
    wire [WIDTH_HEIGHT-1 : 0] inputMem_wr_en;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] inputMem_rd_addr;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] weightMem_rd_data;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] weight_FIFO_to_sysArr;
    wire [WIDTH_HEIGHT-1 : 0] outputMem_wr_en;
    wire [WIDTH_HEIGHT-1 : 0] outputMem_rd_en;
    wire [WIDTH_HEIGHT-1 : 0] cols_valid_out;
    wire [2*WIDTH_HEIGHT*DATA_WIDTH-1 : 0] accumTable_wr_data;
    wire [$clog2(NUM_ACCUM_ROWS)*WIDTH_HEIGHT-1 : 0] accumTable_wr_addr;
    wire [WIDTH_HEIGHT-1 : 0] accumTable_wr_en_in;
    wire [$clog2(NUM_ACCUM_ROWS)*WIDTH_HEIGHT-1 : 0] accumTable_rd_addr;
    wire [2*WIDTH_HEIGHT*DATA_WIDTH-1 : 0] accumTable_data_to_relu;
    wire [2*WIDTH_HEIGHT-1 : 0] outputMem_wr_data;
    wire [WIDTH_HEIGHT-1 : 0] mem_to_fifo_en;
    wire [WIDTH_HEIGHT-1 : 0] fifo_to_sys_arr_en;
    wire [(WIDTH_HEIGHT*DATA_WIDTH)-1 : 0] weightMem_rd_addr;
    wire [WIDTH_HEIGHT-1 : 0] weightMem_rd_en;
    wire [WIDTH_HEIGHT-1 : 0] weightMem_wr_en;
    wire weight_write;
    
    //Activate the sys_array after two cycles of starting reading inputs from the input memory
    wire sys_arr_active;
    reg sys_arr_active1;
    reg sys_arr_active2;
    
    reg data_mem_calc_done_r;    // Set to high when multiply operation is done
    wire data_mem_calc_done , data_mem_calc_en; 
    
    
    wire accum_clear;
    
    wire fifo_to_sys_arr_done;
    
    wire [DATA_WIDTH*WIDTH_HEIGHT-1 : 0] mem_addr_bus_data;
    
    wire [$clog2(WIDTH_HEIGHT)-1 : 0] wr_accumTable_matrix_row_idx;   //This variable represents the row index within one matrix
    wire [$clog2(MAX_MAT_DIM/WIDTH_HEIGHT)-1 : 0] wr_accumTable_submatrix_row; //The row index of the submatrix
    wire [$clog2(MAX_MAT_DIM/WIDTH_HEIGHT)-1 : 0] wr_accumTable_submatrix_col; //The row index of the submatrix
    
    
    wire [$clog2(WIDTH_HEIGHT)-1 : 0] rd_accumTable_matrix_row_idx;   //This variable represents the row index within one matrix
    wire [$clog2(MAX_MAT_DIM/WIDTH_HEIGHT)-1 : 0] rd_accumTable_submatrix_row; //The row index of the submatrix
    wire [$clog2(MAX_MAT_DIM/WIDTH_HEIGHT)-1 : 0] rd_accumTable_submatrix_col; //The row index of the submatrix
    
    
    wire [DATA_WIDTH*WIDTH_HEIGHT-1 : 0] outputMem_wr_addr;
    
    wire in_fifo_active , out_fifo_active;
    wire reset_global;
    wire relu_en;
    
    reg [$clog2(WIDTH_HEIGHT)-1 : 0] wr_row_count;
    reg [$clog2(WIDTH_HEIGHT)-1 : 0] wr_row_count_r;
    
    //-----------------------------------------------------------Modules Instiliaze--------------------------------------------------------------//
    
    
    assign sys_arr_active = inputMem_rd_en[0];
    assign data_mem_calc_done = data_mem_calc_done_r;
    
    //Master Control Module
    
    master_control master_control_module(
        
         .clk(clk),
         .reset(reset),
         .reset_out(reset_global),
         .start(start),
         .done(done),
         .opcode(opcode),
         .dim_1(dim_1),
         .dim_2(dim_2),
         .dim_3(dim_3),
         .addr_1(addr_1),
         .accum_table_submatrix_row_in(accum_table_submatrix_row_in),
         .accum_table_submatrix_col_in(accum_table_submatrix_col_in),
         .weight_fifo_done(fifo_to_sys_arr_done),
         .data_mem_done(data_mem_calc_done),
         .fifo_ready(fifo_ready),
         .bus_to_mem_addr(mem_addr_bus_data),
         .input_mem_wr_en(inputMem_wr_en),
         .weight_mem_out_rd_addr(weightMem_rd_addr),
         .weight_mem_out_rd_en(weightMem_rd_en),
         .weight_mem_wr_en(weightMem_wr_en),
         .output_mem_wr_addr(outputMem_wr_addr),
         .output_mem_wr_en(outputMem_wr_en),
         .output_mem_rd_en(outputMem_rd_en),
         .in_fifo_active(in_fifo_active),
         .out_fifo_active(out_fifo_active),
         .data_mem_en(data_mem_calc_en),
         .wr_submatrix_row_out(wr_accumTable_submatrix_row),
         .wr_submatrix_col_out(wr_accumTable_submatrix_col),
         .wr_row_num(wr_accumTable_matrix_row_idx),
         .rd_submatrix_row_out(rd_accumTable_submatrix_row),
         .rd_submatrix_col_out(wr_accumTable_submatrix_row),
         .rd_row_num(rd_accumTable_matrix_row_idx),
         .accum_clear(accum_clear),
         .relu_en(relu_en)
             
    );
    
    defparam master_control_module.MAX_OUT_ROWS = MAX_MAT_DIM;
    defparam master_control_module.MAX_OUT_COLS = MAX_MAT_DIM;
    defparam master_control_module.SYS_ARR_ROWS = WIDTH_HEIGHT;
    defparam master_control_module.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam master_control_module.ADDR_WIDTH   = ADDR_WIDTH;
    
    
    
    //----------------------------------------Input Side-----------------------------------//
    
    //Systollic array module
    
    SysArray sysArr(
        
        .clk(clk),
        .active(sys_arr_active2),
        .data_in(inputMem_to_sysArr),       //form input memory
        .w_in(weight_FIFO_to_sysArr),       //from weightfifo
        .sum_in(256'd0),
        .weight_wren({16{weight_write}}),   //from fifo_arr
        .mac_out(accumTable_wr_data),       //to AccumlateTable
        .w_out(),                           //not used
        .weight_wren_out(),                 //not used
        .active_out(cols_valid_out),        //enable signals for accumlate table write control
        .data_out()                         //not used
        
    );
    
    defparam sysArr.rows_num = WIDTH_HEIGHT;
    
    
    //Input memory module
    
    memArr input_memory(
        
        .clk(clk),
        .rd_en(inputMem_rd_en),          //from read input memory control unit
        .wr_en(inputMem_wr_en),          //from master control unit
        .wr_data(inputMem_wr_data),      //from the input port of the top module
        .rd_data(inputMem_to_sysArr),    //to sysArr
        .wr_addr(mem_addr_bus_data),     //from master control
        .rd_addr(inputMem_rd_addr)       //from read input memory control unit
        
    );
    
    defparam input_memory.WIDTH_HEIGHT = WIDTH_HEIGHT;
    
    
    //Input memory read control
    
    mem_rd_ctrl inputMemControl(
        
        .clk(clk),
        .reset(reset_global),            //from master_control
        .active(data_mem_calc_en),       //from master_control
        .rd_en(inputMem_rd_en),          //to input_memory
        .rd_addr(inputMem_rd_addr),      //to input memory
        .wr_active()                     //not used
        
    );
    
    
    defparam inputMemControl.WIDTH_HEIGHT = WIDTH_HEIGHT;
    
    
    //Weight Array
    
    memArr weight_memory(
        
        .clk(clk),
        .rd_en(weightMem_rd_en),           //from master_control
        .wr_en(weightMem_wr_en),           //from master_control
        .wr_data(weightMem_wr_data),       //from the input port of the top module
        .rd_data(weightMem_rd_data),       //to weightFIFO
        .rd_addr(weightMem_rd_addr)        //from master_control
        
    );
    
    defparam weight_memory.WIDTH_HEIGHT = WIDTH_HEIGHT;
    
    
    //FIFO control module
    //This fifo control module is responsiable for controlling 
    //the filling process of weight fifo from the weight memory
    FIFO_Ctrl mem_fifo(
        
        .clk(clk),
        .reset(reset_global),             //from master_control
        .active(in_fifo_active),          //from master_control
        .stagger_load(1'b0),
        .fifo_en(mem_to_fifo_en),         //to weightFIFO
        .done(),                          //not used
        .weight_write()                   //not used
        
    );
    
    defparam mem_fifo.FIFO_WIDTH = WIDTH_HEIGHT;
    
    
    //FIFO control module
    //This fifo control module is responsiable for controlling 
    //the process of writing weights from the weightFIFO to SysArr
    
    FIFO_Ctrl fifo_to_sysArr(
        
        .clk(clk),
        .reset(reset_global),             //from master_control
        .active(out_fifo_active),         //from master_control
        .stagger_load(1'b0),
        .fifo_en(fifo_to_sys_arr_en),     //to weightFIFO
        .done(fifo_to_sys_arr_done),      //to master_control
        .weight_write(weight_write)       //not used
        
    );
    
    defparam fifo_to_sysArr.FIFO_WIDTH = WIDTH_HEIGHT;
    
    
    
    //Weight FIFO module
    
    weightFIFO weight_fifo(
        
        .clk(clk), 
        .reset(reset_global),                         //from master_control
        .en(fifo_to_sys_arr_en | mem_to_fifo_en),     //from mem_fifo or fifo_to_sysArr
        .weightIn(weightMem_rd_data) ,                //from weight memory
        .weightOut(weight_FIFO_to_sysArr)             //to sysArr
    
    );
    
    defparam weight_fifo.DATA_WIDTH  = DATA_WIDTH;
    defparam weight_fifo.FIFO_INPUTS = WIDTH_HEIGHT;
    defparam weight_fifo.FIFO_DEPTH  = WIDTH_HEIGHT;
    
    
    //----------------------------------------Output Side-----------------------------------//
    
    //AccumlateTable Module
    
    AccumTable accumTable(
    
        .clk(clk),
        .clear({WIDTH_HEIGHT{reset_global}}),       //from master_control
        .rd_en({WIDTH_HEIGHT{1'b1}}),
        .wr_en(accumTable_wr_en_in),                //from accumlate table write control module
        .rd_address(accumTable_rd_addr),            //from accumlate table read control module
        .wr_address(accumTable_wr_addr),            //from accumlate table write control module
        .rd_data(accumTable_data_to_relu),          //to Relu unit
        .wr_data(accumTable_wr_data)                //from sysArr
        
    );
    
    defparam accumTable.SYS_ARR_ROWS = WIDTH_HEIGHT;
    defparam accumTable.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam accumTable.MAX_ROWS_NUM = MAX_MAT_DIM;
    defparam accumTable.MAX_OUT_COLS = MAX_MAT_DIM;
    defparam accumTable.DATA_WIDTH   = 2*DATA_WIDTH;
    
    
    //AccumTable write control module
    
    AccumTableWrCtrl accumTableWrCtrl(
        
        .clk(clk),
        .reset(reset_global),                            //from master_control
        .wr_en_in(cols_valid_out[0]),                    //from SysArr 
        .sub_row(wr_row_count),                           
        .submat_row_idx(wr_accumTable_submatrix_row),    //from master_control
        .submat_col_idx(wr_accumTable_submatrix_col),    //from master_control
        .wr_en_out(accumTable_wr_en_in),                 //to accumTable
        .wr_addr_out(accumTable_wr_addr)                 //to accumTable
        
    );
    
    defparam accumTableWrCtrl.MAX_OUT_ROWS = MAX_MAT_DIM;
    defparam accumTableWrCtrl.MAX_OUT_COLS = MAX_MAT_DIM;
    defparam accumTableWrCtrl.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam accumTableWrCtrl.SYS_ARR_ROWS = WIDTH_HEIGHT;
    
    //AccumTable read control module
    
    AccumTableRdCtrl accumTableRdCtrl(
        
        .sub_row(rd_accumTable_matrix_row_idx),         //from master control
        .submat_row_idx(rd_accumTable_submatrix_row),   //from master control
        .submat_col_idx(rd_accumTable_submatrix_col),   //from master control
        .rd_addr(accumTable_rd_addr)                    //to accumTable
        
    );
    
    defparam accumTableRdCtrl.MAX_OUT_ROWS = MAX_MAT_DIM;
    defparam accumTableRdCtrl.MAX_OUT_COLS = MAX_MAT_DIM;
    defparam accumTableRdCtrl.SYS_ARR_COLS = WIDTH_HEIGHT;
    defparam accumTableRdCtrl.SYS_ARR_ROWS = WIDTH_HEIGHT;
    
    
    //Relu array module
    
    ReluArr relu_arr(
    
        .en(relu_en),                       //from master_control
        .In(accumTable_data_to_relu),       //from accumTable
        .Out(outputMem_wr_data)             //to output memory
    );
    
    defparam relu_arr.DATA_WIDTH = 2*DATA_WIDTH;
    defparam relu_arr.ARR_INPUTS = WIDTH_HEIGHT;
    
    
    //Output memory module
    
    outputMemArr outputMemory(
        
        .clk(clk),
        .rd_en(outputMem_rd_en),                 //from master_control
        .wr_en(outputMem_wr_en),                 //from master_control
        .wr_data(outputMem_wr_data),       //from ReluArr
        .rd_data(outputMem_rd_data),             //to output port of the top module
        .wr_addr(outputMem_wr_addr),             //from master_control
        .rd_addr(mem_addr_bus_data)              //from master_control
        
    );
    
    
    defparam outputMemory.WIDTH_HEIGHT = WIDTH_HEIGHT;
    
    
    integer i;
    
    always@(*)
    begin
    
        data_mem_calc_done_r = 0;
        
        for(i = 0 ; i < WIDTH_HEIGHT ; i = i + 1)
        begin
        
            data_mem_calc_done_r = data_mem_calc_done_r | cols_valid_out[i];
        
        end
    
    end
    
    
    always@(posedge clk)
    begin
    
        sys_arr_active1 <= sys_arr_active;
        sys_arr_active2 <= sys_arr_active1;    
        wr_row_count    <= wr_row_count_r;
        
    end
    
    
    
    always@(*)
    begin
        
        wr_row_count_r = wr_row_count;
        
        if(reset_global)
        begin
            
            wr_row_count_r = 0;
        
        end
        
        else if(cols_valid_out[0])
        begin
        
            if(wr_row_count < WIDTH_HEIGHT)
            begin
            
                wr_row_count_r = wr_row_count_r + 1;
            
            end
            
            else begin
                
                wr_row_count_r = 0;
            
            end
            
        
        end
    
    end

    
    
    
endmodule
