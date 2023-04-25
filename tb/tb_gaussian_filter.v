`timescale 1ns/1ns
module tb_gaussian_filter(); 
    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 640;
    parameter IMAGE_HEIGHT = 480;

    reg clk, rst;
    reg in_valid, out_ready;
    reg [DATA_WIDTH-1:0] pixel;
    wire out_valid, in_ready;
    wire [DATA_WIDTH-1:0] filtered_pixel;

    gaussian_filter#(
        .DATA_WIDTH    ( DATA_WIDTH ),
        .IMAGE_WIDTH   ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT  ( IMAGE_HEIGHT )
    )u_gaussian_filter(
        .clk         ( clk         ),
        .rst         ( rst         ),
        .in_valid    ( in_valid    ),
        .out_ready   ( out_ready   ),
        .pixel       ( pixel       ),
        .out_valid   ( out_valid   ),
        .in_ready    ( in_ready    ),
        .filtered_pixel  ( filtered_pixel  )
    );

endmodule