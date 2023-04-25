`timescale 1ns/1ns
module tb_gaussian_pyramid(); 

    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 640;
    parameter IMAGE_HEIGHT = 480;
    parameter SCALE = 9;
    parameter LEVELS = 15; // # of pyramid levels (obtained from SCALE)
    parameter OUTPUT_WIDTH = DATA_WIDTH * LEVELS;

    reg                     clk, rst;
    reg                     in_valid;
    reg [LEVELS-1:0]        out_ready;
    reg [DATA_WIDTH-1:0]    pixel;
    wire                    in_ready;
    wire [LEVELS-1:0]       out_valid;
    wire [OUTPUT_WIDTH-1:0] pyramid_pixels; 

    gaussian_pyramid#(
        .DATA_WIDTH   ( DATA_WIDTH ),
        .IMAGE_WIDTH  ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT ( IMAGE_HEIGHT ),
        .SCALE        ( SCALE ),
        .LEVELS       ( LEVELS )
    )dut(
        .clk          ( clk          ),
        .rst          ( rst          ),
        .in_valid     ( in_valid     ),
        .out_ready    ( out_ready    ),
        .pixel        ( pixel        ),
        .in_ready     ( in_ready     ),
        .out_valid    ( out_valid    ),
        .pyramid_pixels  ( pyramid_pixels  )
    );

endmodule 
