`timescale 1ns/1ns
module tb_downsample(); 
    parameter SCALE = 9;
    
    reg clk, rst;
    reg in_valid, out_ready;
    wire out_valid, in_ready;

    downsample#(
        .SCALE     ( SCALE )
    )dut(
        .clk       ( clk       ),
        .rst       ( rst       ),
        .in_valid  ( in_valid  ),
        .out_ready ( out_ready ),
        .out_valid ( out_valid ),
        .in_ready  ( in_ready  )
    );

    always #5 clk = ~clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        in_valid = 0; 
        out_ready = 0; 
        @(posedge clk); 
        rst = 0; 

        repeat (20) begin 
            @(posedge clk); 
            in_valid = 1; 
            out_ready = 1; 
        end
        repeat (5) begin 
            @(posedge clk); 
            in_valid = 1; 
            out_ready = 0; 
        end
        repeat (15) begin 
            @(posedge clk); 
            in_valid = 0; 
            out_ready = 1; 
        end
        repeat (10) begin 
            @(posedge clk); 
            in_valid = 1; 
            out_ready = 1; 
        end
        $stop; 
    end

endmodule 