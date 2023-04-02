`timescale 1ns/1ns
module tb_kernel_shiftreg(); 

    parameter DATA_WIDTH = 8;
    parameter BLOCK_WIDTH = 3;
    parameter OUTPUT_WIDTH = DATA_WIDTH * BLOCK_WIDTH;

    reg                         clk, rst;
    reg [DATA_WIDTH-1:0]        in_data;
    reg                         in_valid;
    reg                         out_ready;
    wire     [OUTPUT_WIDTH-1:0] out_data;
    wire                        in_ready;
    wire                        out_valid;

    kernel_shiftreg #(
        .DATA_WIDTH(DATA_WIDTH),
        .BLOCK_WIDTH(BLOCK_WIDTH) 
    ) dut (
        .clk(clk), .rst(rst), 
        .in_data(in_data), .in_valid(in_valid), 
        .out_ready(out_ready), .out_data(out_data),
        .in_ready(in_ready), .out_valid(out_valid)
    ); 

    always #5 clk = !clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        @(posedge clk);
        rst = 0; 
        in_valid = 1; 
        out_ready = 1; 
        in_data = $random;
        repeat(6) begin 
            @(posedge clk);
            in_data = $random;
        end

        repeat(5) begin 
            @(posedge clk); 
            in_data = $random; 
            in_valid = 0;
            out_ready = 1; 
        end
        repeat(5) begin 
            @(posedge clk); 
            in_data = $random; 
            in_valid = 1;
            out_ready = 0; 
        end
        repeat(10) begin 
            @(posedge clk); 
            in_data = $random; 
            in_valid = 1;
            out_ready = 1; 
        end
        $finish();
    end
    
endmodule