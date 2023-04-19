`timescale 1ns/1ns
module tb_hog();

    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 640;
    parameter IMAGE_HEIGHT = 480; 
    parameter WINDOW_WIDTH = 32 * 36; 

    reg clk, rst;
    reg pixel_valid, window_ready; 
    reg [DATA_WIDTH-1:0] pixel;
    wire window_valid, pixel_ready;
    wire [WINDOW_WIDTH-1:0] detection_window; 

    hog#(
        .DATA_WIDTH   ( 8 ),
        .IMAGE_WIDTH  ( 640 ),
        .IMAGE_HEIGHT ( 480 )
    )dut(
        .clk          ( clk          ),
        .rst          ( rst          ),
        .pixel_valid  ( pixel_valid  ),
        .window_ready ( window_ready ),
        .pixel        ( pixel        ),
        .window_valid ( window_valid ),
        .pixel_ready  ( pixel_ready  ),
        .detection_window  ( detection_window  )
    );

    // only need the modelsim schematic for now...


endmodule