module binning #(
    parameter DATA_WIDTH = 8,
    parameter IMAGE_WIDTH = 640,
    parameter IMAGE_HEIGHT = 480
) (
    input clk, rst, 
    input pixel_valid, bin_ready,
    input [DATA_WIDTH-1:0] pixel, 
    output bin_valid, pixel_ready,
    output [DATA_WIDTH-1:0] magnitude,
    output [3:0] bin
); 

localparam KERNEL_WIDTH = 3 * 3 * 8; 

wire kernel_valid;
wire [KERNEL_WIDTH-1:0] kernel; 
wire [DATA_WIDTH:0] Gx, Gy;
wire [DATA_WIDTH-1:0] Gx_abs, Gy_abs;

wire k_valid, k_ready, k_border; 
wire is_upper_bin; 

lin_buff#(
    .BUFFER_WIDTH ( DATA_WIDTH ),
    .BUFFER_DEPTH ( IMAGE_WIDTH ),
    .BLOCK_WIDTH  ( 3 ),
    .BLOCK_HEIGHT ( 3 )
)image_line_buff(
    .clk          ( clk          ),
    .rst          ( rst          ),
    .p_valid      ( pixel_valid  ),
    .pixel        ( pixel        ),
    .k_ready      ( k_ready      ),
    .p_ready      ( pixel_ready  ),
    .k_border     ( k_border     ),
    .k_valid      ( k_valid      ),
    .kernel       ( kernel       )
);

assign kernel_valid = k_valid && !k_border;

hog_gradient#(
    .KERNEL_WIDTH ( KERNEL_WIDTH )
)u_hog_gradient(
    .clk       ( clk       ),
    .rst       ( rst       ),
    .k_valid   ( kernel_valid ),
    .out_ready ( bin_ready ),
    .kernel    ( kernel    ),
    .k_ready   ( k_ready   ),
    .out_valid ( bin_valid ),
    .Gx        ( Gx        ),
    .Gy        ( Gy        )
);

abs#(
    .DATA_WIDTH   ( DATA_WIDTH )
)u_abs(
    .data_in1     ( Gx     ),
    .data_in2     ( Gy     ),
    .is_upper_bin ( is_upper_bin ),
    .data_out1    ( Gx_abs    ),
    .data_out2    ( Gy_abs    )
);

hog_magnitude#(
    .DATA_WIDTH ( DATA_WIDTH )
)u_hog_magnitude(
    .gx ( Gx_abs ),
    .gy ( Gy_abs ),
    .magnitude  ( magnitude  )
);


hog_orientation#(
    .DATA_WIDTH   ( DATA_WIDTH )
)u_hog_orientation(
    .gx           ( Gx_abs       ),
    .gy           ( Gy_abs       ),
    .is_upper_bin ( is_upper_bin ),
    .bin_out      ( bin          )
);

endmodule