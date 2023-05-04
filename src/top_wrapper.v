module top_wrapper (
    input clk, rst
); 
    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 640;
    parameter IMAGE_HEIGHT = 480;
    parameter WINDOW_WIDTH = 32 * 36;
    parameter SCALE = 9;
    // only these SCALE values are valid
    parameter LEVELS = SCALE==9? 15: 
                       SCALE==6? 10:
                       SCALE==6? 8 : 
                       SCALE==4? 7 : 
                       SCALE==3? 6 : 
                       SCALE==2? 5 : 
                                 4 ;
    parameter OUTPUT_WIDTH = WINDOW_WIDTH * LEVELS;

    top#(
        .DATA_WIDTH       ( DATA_WIDTH ),
        .IMAGE_WIDTH      ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT     ( IMAGE_HEIGHT ),
        .WINDOW_WIDTH     ( WINDOW_WIDTH ),
        .SCALE            ( SCALE ),
        .LEVELS           ( LEVELS )
    )u_top(
        .clk              ( clk              ),
        .rst              ( rst              ),
        .pixel_in         ( pixel_in         ),
        .pixel_valid      ( pixel_valid      ),
        .window_ready     ( window_ready     ),
        .pixel_ready      ( pixel_ready      ),
        .detection_window ( detection_window ),
        .window_valid     ( window_valid     )
    );


endmodule