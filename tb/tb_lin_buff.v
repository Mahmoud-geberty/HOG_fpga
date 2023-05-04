`timescale 1ns/1ns
module tb_lin_buff();
    parameter BUFFER_WIDTH = 8;
    parameter BUFFER_DEPTH = 9;
    parameter BLOCK_WIDTH  = 3;
    parameter BLOCK_HEIGHT = 3;
    parameter OUTPUT_WIDTH = BLOCK_WIDTH * BLOCK_HEIGHT * BUFFER_WIDTH;

    reg                     clk, rst;
    reg                     p_valid; 
    reg                     k_ready; 
    reg [BUFFER_WIDTH-1:0]  pixel;
    wire                    p_ready; 
    wire                    k_border;
    wire                    k_valid;
    wire [OUTPUT_WIDTH-1:0] kernel;

    lin_buff #(
        .BUFFER_WIDTH(BUFFER_WIDTH), 
        .BUFFER_DEPTH(BUFFER_DEPTH),
        .BLOCK_WIDTH(BLOCK_WIDTH)
    ) dut (
        .clk(clk), .rst(rst), 
        .p_valid(p_valid), .pixel(pixel), 
        .p_ready(p_ready), .k_border(k_border), 
        .k_valid(k_valid), .kernel(kernel), 
        .k_ready(k_ready)
    );

    always #5 clk = !clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        @(posedge clk);
        rst = 0; 
        pixel = $random;
        p_valid = 1; 
        k_ready = 1; 
        repeat(8) begin 
            @(posedge clk);
            pixel = $random;
        end
        repeat(5) begin 
            @(posedge clk);
            pixel = $random;
            p_valid = 0; 
        end
        repeat(20) begin 
            @(posedge clk);
            pixel = $random;
            p_valid = 1; 
        end
        repeat(8) begin 
            @(posedge clk);
            pixel = $random;
            p_valid = 0; 
        end
        repeat(20) begin 
            @(posedge clk);
            pixel = $random;
            p_valid = 1; 
        end
        $stop();
    end

endmodule