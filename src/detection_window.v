module detection_window #(
    parameter IMAGE_WIDTH = 640,
    parameter INPUT_WIDTH = 36,
    parameter BLOCKS_PER_WINDOW = 32,
    parameter OUTPUT_WIDTH = INPUT_WIDTH * BLOCKS_PER_WINDOW
) (
    input clk, rst, 
    input in_valid, out_ready,
    input [INPUT_WIDTH-1:0] normalized_block,
    output [OUTPUT_WIDTH-1:0] detection_window
); 

localparam BUFFER_WIDTH = IMAGE_WIDTH / 64;
localparam IMAGE_ROW_BLOCKS  = IMAGE_WIDTH / 16; 
localparam WINDOW_ROW_BLOCKS = 64/16;
localparam WINDOW_COLUMN_BLOCKS = 128/16; 

lin_buff#(
    .BUFFER_WIDTH ( INPUT_WIDTH ),
    .BUFFER_DEPTH ( IMAGE_ROW_BLOCKS ),
    .BLOCK_WIDTH  ( WINDOW_ROW_BLOCKS ),
    .BLOCK_HEIGHT ( WINDOW_COLUMN_BLOCKS )
) block_line_buffer (
    .clk          ( clk          ),
    .rst          ( rst          ),
    .p_valid      ( in_valid     ),
    .pixel        ( normalized_block ),
    .k_ready      ( out_ready      ),
    .p_ready      ( in_ready      ),
    .k_border     ( k_border     ),
    .k_valid      ( k_valid      ),
    .kernel       ( detection_window )
);

assign out_valid = k_valid & !k_border;

endmodule