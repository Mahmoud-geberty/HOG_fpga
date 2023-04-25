module kernel #(
    parameter BLOCK_WIDTH = 3, 
    parameter BLOCK_HEIGHT = 3, 
    parameter DATA_WIDTH = 8,
    parameter INPUT_WIDTH = DATA_WIDTH * BLOCK_HEIGHT,
    parameter OUTPUT_WIDTH = BLOCK_WIDTH * BLOCK_HEIGHT * DATA_WIDTH
) (
    input clk, rst, 
    input [INPUT_WIDTH-1:0] in_pixels, 
    input [BLOCK_HEIGHT-1:0] in_valid,
    input [BLOCK_HEIGHT-1:0] out_ready, 
    output [OUTPUT_WIDTH-1:0] out_pixels,
    output [BLOCK_HEIGHT-1:0] in_ready,
    output [BLOCK_HEIGHT-1:0] out_valid,
    output                    kernel_valid
);

    parameter KERNEL_ROW_SIZE = BLOCK_WIDTH * DATA_WIDTH;

    assign kernel_valid = out_valid[BLOCK_HEIGHT-1];

    genvar i;
    generate 
        for (i = 0; i < BLOCK_HEIGHT; i = i + 1) begin : KERNEL
            kernel_shiftreg #(
                .DATA_WIDTH(DATA_WIDTH),
                .BLOCK_WIDTH(BLOCK_WIDTH)
            ) shiftreg (
                .clk(clk), .rst(rst),
                .in_data(in_pixels[i*DATA_WIDTH +: DATA_WIDTH]), 
                .in_valid(in_valid[i]),
                .out_ready(out_ready[i]), 
                .in_ready(in_ready[i]),
                .out_valid(out_valid[i]), 
                .out_data(out_pixels[i*KERNEL_ROW_SIZE +: KERNEL_ROW_SIZE])
            ); 
        end
    endgenerate

endmodule