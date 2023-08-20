`timescale 1ns / 1ps



module tb_fifio_ctrl();

    reg clk, reset, active, stagger_load;
    reg [15:0] fifo_en;
    reg [127:0] weightIn;
    wire [15:0] fifo_en_out;
    wire [127:0] weightOut;
    wire done;
    
    always begin
      #5;
      clk = ~clk;
    end
    
    initial begin
    
      clk = 0;
      reset = 1;
      active = 0;
      #10;
      reset = 0;
      #10;
      active = 1;
      stagger_load = 0;
      
      repeat(16) begin
        fifo_en = fifo_en_out;
        weightIn = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
                   8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16};
        #10;
      end
      
      fifo_en = 0;
      #10;
      #10;
      //$stop;
      
      active = 1;
      stagger_load = 1;
      weightIn = 0;
      
      repeat(32) begin
          fifo_en = fifo_en_out;
          $display(weightOut);
          #10;
      end
      $stop;
      
    end
    
    FIFO_Ctrl fifo_ctrl(
        
        .clk(clk),
        .reset(reset),
        .active(active),
        .stagger_load(stagger_load),
        .fifo_en(fifo_en_out),
        .done(done)
        
    );

    
    weightFIFO tb_weight_fifo (.clk(clk) , .reset(reset) , .en(fifo_en) , .weightIn(weightIn) , .weightOut(weightOut));

    defparam tb_weight_fifo.FIFO_INPUTS = 16;
    defparam tb_weight_fifo.FIFO_DEPTH = 16;
    
    
    
endmodule
