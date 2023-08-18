`timescale 1ns / 1ps



module FIFO_Ctrl(
    
    clk,
    reset,
    active,
    stagger_load,
    fifo_en,
    done,
    weight_write
    
);
    
    parameter FIFO_WIDTH = 16;
    localparam COUNT_WIDTH = $clog2(FIFO_WIDTH) + 1;  //A one is added to $clog2(FIFO_WIDTH) so incase of staggered loading 
                                                      //In which counter need to count to 2*FIFO_width instead of only FIFO_WIDTH.
                                                      
    
    input clk;
    input reset;
    input active;
    input stagger_load;
    output wire [FIFO_WIDTH-1 : 0] fifo_en;
    output wire done;
    output wire weight_write;
    
    
    //Using double latching techniques to prevent race conditions and unexpected behaviour of the code
    reg started , started_r;
    reg [COUNT_WIDTH-1 : 0] count , count_r;
    reg stagger_latch , stagger_latch_r;
    
    assign fifo_en = {FIFO_WIDTH{started}};
    assign done    = ~(started || active);
    assign weight_write = (started && (count < 15));
    
    
    always@(*)
    begin
    
        started_r = started;
        count_r   = count;
        stagger_latch_r = stagger_latch;
        
        if(active && !started)
        begin
            
            started_r = 1'b1;
            stagger_latch_r = stagger_load;
            count_r   = {COUNT_WIDTH{1'b0}};
        
        end
        
        
        if(started)
        begin
        
            count_r = count_r + 1;
            
            if(stagger_latch)
            begin
            
                if(count == FIFO_WIDTH*2 - 1)
                begin
                
                    started_r = 1'b0;
                
                end
            
            end
            
            else begin
            
                if(count == FIFO_WIDTH*2 - 1)
                begin
                
                    started_r = 1'b0;
                
                end
            
            end
        
        end
        
        if(reset)
        begin
        
            started_r = 1'b0;
            count_r   = {COUNT_WIDTH{1'b0}};
            stagger_latch_r = stagger_load;
        
        end
    
    end
    
    always@(posedge clk)
    begin
    
        started <= started_r;
        count   <= count_r;
        stagger_latch <= stagger_latch_r;
        
    end

endmodule
