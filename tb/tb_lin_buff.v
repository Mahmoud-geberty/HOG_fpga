`timescale 1ns/1ns
module tb_lin_buff();
    parameter BUFFER_WIDTH = 8;
    parameter BUFFER_DEPTH = 40;
    parameter BLOCK_WIDTH  = 4;
    parameter BLOCK_HEIGHT = 8;
    parameter OUTPUT_WIDTH = BLOCK_WIDTH * BLOCK_HEIGHT * BUFFER_WIDTH;

    reg                     clk, rst;
    reg                     p_valid; 
    reg                     k_ready; 
    reg [BUFFER_WIDTH-1:0]  pixel;
    wire                    p_ready; 
    wire                    k_border;
    wire                    k_valid;
    wire [OUTPUT_WIDTH-1:0] kernel;

    wire [BUFFER_WIDTH-1:0] kernel_2d [0:BLOCK_HEIGHT-1][BLOCK_WIDTH-1:0];

    genvar i,j; 
    for (i = 0; i < BLOCK_HEIGHT; i = i + 1) begin 
        for (j = 0; j < BLOCK_WIDTH; j = j + 1) begin 
            assign kernel_2d[i][j] = kernel[(i*BLOCK_WIDTH*BUFFER_WIDTH)+(j*BUFFER_WIDTH) +: BUFFER_WIDTH];
        end
    end

    // TODO: write the input image to a file for ease of debugging later
    

    lin_buff #(
        .BUFFER_WIDTH(BUFFER_WIDTH), 
        .BUFFER_DEPTH(BUFFER_DEPTH),
        .BLOCK_WIDTH(BLOCK_WIDTH), 
        .BLOCK_HEIGHT(BLOCK_HEIGHT)
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
        repeat(900) begin 
            @(posedge clk);
            pixel = $random;
            p_valid = 1; 
        end
        $stop();
    end

endmodule