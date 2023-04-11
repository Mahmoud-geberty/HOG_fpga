// takes  cell histograms and produces normalized blocks

// TODO: wire the k_border signal

module norm_block#(
    parameter IMAGE_WIDTH        = 640,
    parameter IMAGE_HEIGHT       = 480,
    parameter CELL_ROW_PIXELS    = 8,
    parameter CELL_COLUMN_PIXELS = 8,
    parameter BLOCK_ROW_CELLS    = 2,
    parameter BLOCK_COLUMN_CELLS = 2,
    parameter BIN_WIDTH          = 14, 
    parameter BINS               = 9, // 10th bin is the sum
    parameter HISTOGRAM_WIDTH    = BIN_WIDTH * (BINS+1),
    parameter CELLS_PER_BLOCK    = 4, 
    parameter BLOCK_HIST_WIDTH   = HISTOGRAM_WIDTH * CELLS_PER_BLOCK,
    parameter OUTPUT_WIDTH       = BINS * CELLS_PER_BLOCK
)( 
    input                       clk, rst,
    input                       in_valid, out_ready,
    input [HISTOGRAM_WIDTH-1:0] cell_histogram,
    output                      out_valid, in_ready,
    output [OUTPUT_WIDTH-1:0]   normalized_block
);
    
    localparam CELLS_PER_LINE = IMAGE_WIDTH / 8;

    wire [BLOCK_HIST_WIDTH-1:0] block_histograms;

    // initialize the line buffer
    lin_buff#(
        .BUFFER_WIDTH ( HISTOGRAM_WIDTH    ),
        .BUFFER_DEPTH ( CELLS_PER_LINE     ),
        .BLOCK_WIDTH  ( BLOCK_ROW_CELLS    ),
        .BLOCK_HEIGHT ( BLOCK_COLUMN_CELLS )
    )cell_line_buffer(
        .clk          ( clk            ),
        .rst          ( rst            ),
        .p_valid      ( in_valid       ),
        .pixel        ( cell_histogram ),
        .k_ready      ( out_ready      ),
        .p_ready      ( in_ready       ),
        .k_border     ( k_border       ),
        .k_valid      ( k_valid        ),
        .kernel       ( block_histograms )
    );

    // initialize the normalization module 
    
    normalization#(
        .BIN_WIDTH        ( BIN_WIDTH ),
        .BINS             ( BINS ),
        .CELLS_PER_BLOCK  ( CELLS_PER_BLOCK )
    )u_normalization(
        .in_valid         ( k_valid          ),
        .k_border         ( k_border         ),
        .block_histograms ( block_histograms ),
        .out_valid        ( out_valid        ),
        .normalized_block ( normalized_block )
    );

endmodule