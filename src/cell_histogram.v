module cell_histogram #(
    parameter DATA_WIDTH       = 8, // magnitude data width
    parameter IMAGE_WIDTH      = 640, // default 480p, width in pixels
    parameter INPUT_BIN_WIDTH  = 11,
    parameter OUTPUT_BIN_WIDTH = 14,
    parameter HISTOGRAM_WIDTH  = OUTPUT_BIN_WIDTH * 9
)(
    input                        clk, rst, 
    input                        in_valid, out_ready, 
    input [DATA_WIDTH-1:0]       magnitude, 
    input [3:0]                  bin_index, 
    output                       out_valid, in_ready, 
    output [HISTOGRAM_WIDTH-1:0] full_histogram // one full histogram output
); 

    localparam BINS                         = 9;
    localparam PARTIAL_HISTOGRAM_WIDTH      = INPUT_BIN_WIDTH * BINS;
    localparam CELL_PARTIAL_HISTOGRAM_WIDTH = PARTIAL_HISTOGRAM_WIDTH * 8;
    localparam CELLS_PER_ROW                = IMAGE_WIDTH / 8; 

    wire [PARTIAL_HISTOGRAM_WIDTH-1:0]      row_histogram;
    wire [CELL_PARTIAL_HISTOGRAM_WIDTH-1:0] partial_histogram;

    row_histogram#(
        .DATA_WIDTH ( DATA_WIDTH ),
        .BIN_WIDTH  ( INPUT_BIN_WIDTH )
    )u_row_histogram(
        .clk        ( clk        ),
        .rst        ( rst        ),
        .in_valid   ( in_valid   ),
        .out_ready  ( p_ready    ),
        .magnitude  ( magnitude  ),
        .bin_index  ( bin_index  ),
        .out_valid  ( p_valid    ),
        .in_ready   ( in_ready  ),
        .row_histogram  ( row_histogram  )
    );


    lin_buff#(
        .BUFFER_WIDTH ( PARTIAL_HISTOGRAM_WIDTH ),
        .BUFFER_DEPTH ( CELLS_PER_ROW ),
        .BLOCK_WIDTH  ( 1 ),
        .BLOCK_HEIGHT ( 8 )
    )cell_buff(
        .clk          ( clk          ),
        .rst          ( rst          ),
        .p_valid      ( p_valid      ),
        .pixel        ( row_histogram),
        .k_ready      ( out_ready    ),
        .p_ready      ( p_ready      ),
        .k_border     ( k_border     ),
        .k_valid      ( out_valid    ),
        .kernel       ( partial_histogram )
    );


    partial_histogram_add#(
        .INPUT_BIN_WIDTH   ( INPUT_BIN_WIDTH  ),
        .OUTPUT_BIN_WIDTH  ( OUTPUT_BIN_WIDTH ),
        .BINS              ( BINS             )
    )histogram_adder(
        .partial_histogram ( partial_histogram ),
        .full_histogram    ( full_histogram    )
    );



endmodule