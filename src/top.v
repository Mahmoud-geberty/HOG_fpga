/*
2. Figure out how many scales to output, either constant or depends on scale 
- 1.10 (15), 1.15 (10), 1.20 (8), 1.25(7), 1.30(6), 1.35(5), 1.40(4), 1.45(5), 1.50(5)
3. Find the skip count value for each scale and how it changes in levels.
- 1.10 (mod9), 1.15(6), 1.2(5), 1.25(4), 1.3(3), 1.35(2), 1.40(2), 1.45(2), 1.5(1)
*/
module top #(
    parameter DATA_WIDTH = 8, 
    parameter IMAGE_WIDTH = 640, 
    parameter IMAGE_HEIGHT = 480, 
    parameter WINDOW_WIDTH = 32 * 36, 
    parameter SCALE = 9,
    // only these SCALE values are valid
    parameter LEVELS = SCALE==9? 15: 
                       SCALE==6? 10:
                       SCALE==6? 8 : 
                       SCALE==4? 7 : 
                       SCALE==3? 6 : 
                       SCALE==2? 5 : 
                                 4 ,
    parameter OUTPUT_WIDTH = WINDOW_WIDTH * LEVELS
) (
    input clk, rst, 
    input [DATA_WIDTH-1:0] pixel_in,    
    input pixel_valid, 
    input [LEVELS-1:0] window_ready,
    output pixel_ready,
    output [OUTPUT_WIDTH-1:0] detection_window, 
    output [LEVELS-1:0] window_valid
); 

    localparam GAUSS_DATA_WIDTH = DATA_WIDTH * LEVELS; 

    wire [LEVELS-1:0] gaussian_valid; 
    wire [GAUSS_DATA_WIDTH-1:0] pyramid_pixels; 
    wire [LEVELS-1:0] hog_pixel_ready;
    
    gaussian_pyramid#(
        .DATA_WIDTH   ( DATA_WIDTH ),
        .IMAGE_WIDTH  ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT ( IMAGE_HEIGHT ),
        .SCALE        ( SCALE ),
        .LEVELS       ( LEVELS )
    )u_gaussian_pyramid(
        .clk          ( clk          ),
        .rst          ( rst          ),
        .in_valid     ( pixel_valid  ),
        .out_ready    ( hog_pixel_ready ),
        .pixel        ( pixel_in     ),
        .in_ready     ( pixel_ready  ),
        .out_valid    ( gaussian_valid ),
        .pyramid_pixels  ( pyramid_pixels  )
    );


    genvar i;

    generate 
        for (i = 0; i < LEVELS; i = i + 1) begin: HOG 
            hog#(
                .DATA_WIDTH   ( DATA_WIDTH ),
                .IMAGE_WIDTH  ( IMAGE_WIDTH ),
                .IMAGE_HEIGHT ( IMAGE_HEIGHT ),
                .WINDOW_WIDTH ( WINDOW_WIDTH )
            )u_hog(
                .clk          ( clk          ),
                .rst          ( rst          ),
                .pixel_valid  ( gaussian_valid[i] ),
                .window_ready ( window_ready[i] ),
                .pixel        ( pyramid_pixels[i*DATA_WIDTH +: DATA_WIDTH] ),
                .window_valid ( window_valid[i] ),
                .pixel_ready  ( hog_pixel_ready[i]  ),
                .detection_window  ( detection_window[i*WINDOW_WIDTH +: WINDOW_WIDTH] )
            );

        end
    endgenerate

endmodule 