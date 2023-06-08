module gaussian_filter #(
    parameter DATA_WIDTH = 8, 
    parameter IMAGE_WIDTH = 640, 
    parameter IMAGE_HEIGHT = 480
) (
    input                   clk, rst,
    input                   in_valid, out_ready, 
    input [DATA_WIDTH-1:0]  pixel, 
    output                  out_valid, in_ready, 
    output [DATA_WIDTH-1:0] filtered_pixel
); 

    localparam KERNEL_WIDTH  = 3; 
    localparam KERNEL_HEIGHT = 3; 
    localparam KERNEL_SIZE   = KERNEL_WIDTH * KERNEL_HEIGHT * DATA_WIDTH; 

    wire [KERNEL_SIZE-1:0] kernel; 
    wire                   kernel_valid; 

    wire k_valid, k_ready, k_border;

    lin_buff#(
        .BUFFER_WIDTH ( DATA_WIDTH ),
        .BUFFER_DEPTH ( IMAGE_WIDTH ),
        .BLOCK_WIDTH  ( KERNEL_WIDTH ),
        .BLOCK_HEIGHT ( KERNEL_HEIGHT )
    )u_lin_buff(
        .clk          ( clk          ),
        .rst          ( rst          ),
        .p_valid      ( in_valid     ),
        .pixel        ( pixel        ),
        .k_ready      ( k_ready      ),
        .p_ready      ( in_ready     ),
        .k_border     ( k_border     ),
        .k_valid      ( k_valid      ),
        .kernel       ( kernel       )
    );

    assign kernel_valid = k_valid && !k_border;

    gaussian_operator#(
        .DATA_WIDTH    ( DATA_WIDTH    ),
        .KERNEL_WIDTH  ( KERNEL_WIDTH  ), 
        .KERNEL_HEIGHT ( KERNEL_HEIGHT )
    )u_gaussian_operator(
        .in_valid   ( kernel_valid ),
        .out_ready  ( out_ready  ),
        .kernel     ( kernel     ),
        .out_valid  ( out_valid  ),
        .in_ready   ( k_ready   ),
        .data_out   ( filtered_pixel   )
    );

endmodule