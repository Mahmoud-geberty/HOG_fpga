`timescale 1ns/1ns
module tb_kernel(); 
    parameter BLOCK_WIDTH = 3;
    parameter BLOCK_HEIGHT = 3;
    parameter DATA_WIDTH = 8;
    parameter INPUT_WIDTH = DATA_WIDTH * BLOCK_HEIGHT;
    parameter OUTPUT_WIDTH = BLOCK_WIDTH * BLOCK_HEIGHT * DATA_WIDTH;

    reg clk, rst;
    reg [INPUT_WIDTH-1:0] in_pixels;
    reg [BLOCK_HEIGHT-1:0] in_valid;
    reg [BLOCK_HEIGHT-1:0] out_ready;
    wire [OUTPUT_WIDTH-1:0] out_pixels;
    wire [BLOCK_HEIGHT-1:0] in_ready;
    wire [BLOCK_HEIGHT-1:0] out_valid;
    wire                    kernel_valid;

    kernel #(
        .DATA_WIDTH(DATA_WIDTH),
        .BLOCK_HEIGHT(BLOCK_HEIGHT),
        .BLOCK_WIDTH(BLOCK_WIDTH) 
    ) dut (
        .clk(clk), .rst(rst), 
        .in_pixels(in_pixels), .in_valid(in_valid), 
        .out_ready(out_ready), .out_pixels(out_pixels),
        .in_ready(in_ready), .out_valid(out_valid),
        .kernel_valid(kernel_valid)
    ); 

    always #5 clk = !clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        @(posedge clk);
        rst = 0; 
        in_valid = 3'b111; 
        out_ready = 3'b111; 
        in_pixels = $random;
        repeat(6) begin 
            @(posedge clk);
            in_pixels = $random;
        end

        repeat(5) begin 
            @(posedge clk); 
            in_pixels = $random; 
            in_valid = 3'b110;
            out_ready = 3'b111; 
        end
        repeat(5) begin 
            @(posedge clk); 
            in_pixels = $random; 
            in_valid = 3'b011;
            out_ready = 3'b110; 
        end
        repeat(5) begin 
            @(posedge clk); 
            in_pixels = $random; 
            in_valid = 3'b101;
            out_ready = 3'b111; 
        end
        repeat(20) begin 
            @(posedge clk); 
            in_pixels = $random; 
            in_valid = 3'b111;
            out_ready = 3'b111; 
        end
        $finish();
    end

endmodule