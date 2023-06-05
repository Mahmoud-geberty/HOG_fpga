`timescale 1ns/1ns
module tb_top(); 
    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 320;
    parameter IMAGE_HEIGHT = 420;
    parameter WINDOW_WIDTH = 32 * 36;
    parameter SCALE = 4;
    // only these SCALE values are valid
    parameter LEVELS = SCALE==9? 15: 
                       SCALE==6? 10:
                       SCALE==6? 8 : 
                       SCALE==4? 7 : 
                       SCALE==3? 6 : 
                       SCALE==2? 5 : 
                                 4 ;
    parameter OUTPUT_WIDTH = WINDOW_WIDTH * LEVELS;

    reg clk, rst;
    reg [DATA_WIDTH-1:0] pixel_in;
    reg pixel_valid;
    reg [LEVELS-1:0] window_ready;
    wire [OUTPUT_WIDTH-1:0] detection_window;
    wire pixel_ready;
    wire [LEVELS-1:0] window_valid; 

    top#(
        .DATA_WIDTH       ( DATA_WIDTH ),
        .IMAGE_WIDTH      ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT     ( IMAGE_HEIGHT ),
        .WINDOW_WIDTH     ( WINDOW_WIDTH ),
        .SCALE            ( SCALE )
    )dut(
        .clk              ( clk              ),
        .rst              ( rst              ),
        .pixel_in         ( pixel_in         ),
        .pixel_valid      ( pixel_valid      ),
        .window_ready     ( window_ready     ),
        .detection_window ( detection_window ),
        .pixel_ready      ( pixel_ready      ),
        .window_valid     ( window_valid     )
    );

    always #50 clk = ~clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        pixel_in = 0; 
        pixel_valid = 0; 
        window_ready = {15{1'b1}}; 

        repeat(1000) begin 
            @(posedge clk); 
            rst = 0; 
            pixel_in = $random; 
            pixel_valid = 1; 
        end

        $stop; 
    end
    
endmodule 