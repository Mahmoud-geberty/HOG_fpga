/*
    SCRATCH PAD
    This filters and then downsamples several times (depending on scale??). 
    I am wondering if I need to maintain the image size this time?. In which 
    case I would need to change the image buffer. I think for now I'll just skip
    that. therefore...

    TODO: 
        1. Figure out what scales to support
        -   increments of 0.05 from 1.10 to 1.5
        2. Figure out how many scales to output, either constant or depends on scale 
        - 1.10 (15), 1.15 (10), 1.20 (8), 1.25(7), 1.30(6), 1.35(5), 1.40(4), 1.45(5), 1.50(5)
        3. Find the skip count value for each scale and how it changes in levels.
        - 1.10 (mod9), 1.15(6), 1.2(5), 1.25(4), 1.3(3), 1.35(2), 1.40(2), 1.45(2), 1.5(1)
*/
module gaussian_pyramid #(
    parameter DATA_WIDTH = 8,
    parameter IMAGE_WIDTH = 640, 
    parameter IMAGE_HEIGHT = 480, 
    parameter SCALE = 9, 
    parameter LEVELS = 15, // # of pyramid levels (obtained from SCALE)
    parameter OUTPUT_WIDTH = DATA_WIDTH * LEVELS
)(
    input                     clk, rst, 
    input                     in_valid, 
    input [LEVELS-1:0]        out_ready, 
    input [DATA_WIDTH-1:0]    pixel, 
    output                    in_ready, 
    output [LEVELS-1:0]       out_valid,
    output [OUTPUT_WIDTH-1:0] pyramid_pixels
); 
    // inter-level signals

    // valid signals 
    wire [LEVELS-1:0] ds_valid; 
    wire [LEVELS-1:0] filter_valid; 

    // wire [LEVELS-1:0] ds_ready; 

    // ds to gauss_f ready signal
    wire [LEVELS-1:0] ds_g_ready; 

    // ds input indicating destination is ready to recieve the output
    wire [LEVELS-1:0] ds_out_ready; 

    // g to ds ready signal
    wire [LEVELS-1:0] g_ds_ready; 

    // gauss filter inputs (concatenated) 
    wire [OUTPUT_WIDTH-1:0] in_pixel; 

    assign in_pixel[0+:DATA_WIDTH] = pixel; 
    assign ds_valid[0] = in_valid; 
    assign in_ready = g_ds_ready[0]; 
    assign ds_out_ready[LEVELS-1] = out_ready[LEVELS-1]; 

    genvar i; 

    generate
        for (i = 1; i < LEVELS; i = i + 1) begin : IN_PIXEL 
            assign in_pixel[i*DATA_WIDTH +: DATA_WIDTH] = 
                pyramid_pixels[(i-1)*DATA_WIDTH +: DATA_WIDTH];
        end

        for (i = 1; i < LEVELS; i = i + 1) begin : DS_VALID
            assign ds_valid[i] = out_valid[i-1]; 
        end

        for (i = 1; i < LEVELS; i = i + 1) begin : DS_OUT_READY
            assign ds_out_ready[i-1] = g_ds_ready[i] && out_ready[i-1]; 
        end

        for (i = 0; i < LEVELS; i = i + 1) begin : PYRAMID
            gaussian_filter#(
                .DATA_WIDTH  ( DATA_WIDTH ),
                .IMAGE_WIDTH ( IMAGE_WIDTH ),
                .IMAGE_HEIGHT ( IMAGE_HEIGHT )
            )u_gaussian_filter(
                .clk         ( clk         ),
                .rst         ( rst         ),
                .in_valid    ( ds_valid[i] ),
                .out_ready   ( ds_g_ready[i] ),
                .pixel       ( in_pixel[i*DATA_WIDTH +: DATA_WIDTH] ),
                .out_valid   ( filter_valid[i] ),
                .in_ready    ( g_ds_ready[i]    ),
                .filtered_pixel  ( pyramid_pixels[i*DATA_WIDTH+:DATA_WIDTH] )
            );

            downsample#(
                .SCALE     ( SCALE )
            )u_downsample(
                .clk       ( clk       ),
                .rst       ( rst       ),
                .in_valid  ( filter_valid[i] ),
                .out_ready ( ds_out_ready[i] ),
                .out_valid ( out_valid[i] ),
                .in_ready  ( ds_g_ready[i]  )
            );
        end
    endgenerate

endmodule 