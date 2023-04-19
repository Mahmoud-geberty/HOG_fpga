module hog #(
    parameter DATA_WIDTH = 8, 
    parameter IMAGE_WIDTH = 640, 
    parameter IMAGE_HEIGHT = 480,
    parameter WINDOW_WIDTH = 32 * 36
)(
    input clk, rst, 
    input pixel_valid, window_ready,
    input [DATA_WIDTH-1:0] pixel,
    output window_valid, pixel_ready,
    output [WINDOW_WIDTH-1:0] detection_window
); 

localparam HISTOGRAM_WIDTH = 10 * 14; // BINS * BIN_WIDTH
localparam NORM_BLOCK_WIDTH = 36; 

wire [DATA_WIDTH-1: 0]      magnitude; 
wire [3:0]                  bin;
wire [HISTOGRAM_WIDTH-1:0]  cell_histogram; 
wire [NORM_BLOCK_WIDTH-1:0] normalized_block;

binning#(
    .DATA_WIDTH  ( DATA_WIDTH ),
    .IMAGE_WIDTH ( IMAGE_WIDTH ),
    .IMAGE_HEIGHT ( IMAGE_HEIGHT )
)u_binning(
    .clk         ( clk         ),
    .rst         ( rst         ),
    .pixel_valid ( pixel_valid ),
    .bin_ready   ( bin_ready   ),
    .pixel       ( pixel       ),
    .bin_valid   ( bin_valid   ),
    .pixel_ready ( pixel_ready ),
    .magnitude   ( magnitude   ),
    .bin         ( bin         )
);

cell_histogram#(
    .DATA_WIDTH       ( DATA_WIDTH ),
    .IMAGE_WIDTH      ( IMAGE_WIDTH ),
    .INPUT_BIN_WIDTH  ( 11 ),
    .OUTPUT_BIN_WIDTH ( 14 )
)u_cell_histogram(
    .clk              ( clk              ),
    .rst              ( rst              ),
    .in_valid         ( bin_valid        ),
    .out_ready        ( cell_ready       ),
    .magnitude        ( magnitude        ),
    .bin_index        ( bin              ),
    .out_valid        ( cell_valid       ),
    .in_ready         ( bin_ready        ),
    .full_histogram   ( cell_histogram   )
);


norm_block#(
    .IMAGE_WIDTH        ( IMAGE_WIDTH ),
    .IMAGE_HEIGHT       ( IMAGE_HEIGHT )
    // keep these default for now
    // .CELL_ROW_PIXELS    ( 8 ),
    // .CELL_COLUMN_PIXELS ( 8 ),
    // .BLOCK_ROW_CELLS    ( 2 ),
    // .BLOCK_COLUMN_CELLS ( 2 ),
    // .BIN_WIDTH          ( 14 ),
    // .BINS               ( 9 ),
    // .CELLS_PER_BLOCK    ( 4 ),
)u_norm_block(
    .clk                ( clk                ),
    .rst                ( rst                ),
    .in_valid           ( cell_valid         ),
    .out_ready          ( block_ready        ),
    .cell_histogram     ( cell_histogram     ),
    .out_valid          ( block_valid        ),
    .in_ready           ( cell_ready         ),
    .normalized_block   ( normalized_block   )
);

detection_window#(
    .IMAGE_WIDTH       ( IMAGE_WIDTH )
    // .INPUT_WIDTH       ( 36 ),
    // .BLOCKS_PER_WINDOW ( 32 )
)u_detection_window(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .in_valid          ( block_valid       ),
    .out_ready         ( window_ready      ),
    .normalized_block  ( normalized_block  ),
    .out_valid         ( window_valid      ),
    .in_ready          ( block_ready       ),
    .detection_window  ( detection_window  )
);

endmodule