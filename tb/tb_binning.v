`timescale 1ns/1ns
module tb_binning(); 
// just need this to generate a schematic for the design in modelsim 

    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 640;
    parameter IMAGE_HEIGHT = 480;

    reg clk, rst;
    reg pixel_valid, bin_ready;
    wire bin_valid, pixel_ready;
    wire [DATA_WIDTH-1:0] magnitude;
    wire [3:0] bin;

    binning#(
        .DATA_WIDTH  ( DATA_WIDTH ),
        .IMAGE_WIDTH ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT ( IMAGE_HEIGHT )
    )dut(
        .clk         ( clk         ),
        .rst         ( rst         ),
        .pixel_valid ( pixel_valid ),
        .bin_ready   ( bin_ready   ),
        .bin_valid   ( bin_valid   ),
        .pixel_ready ( pixel_ready ),
        .magnitude   ( magnitude   ),
        .bin         ( bin         )
    );


endmodule