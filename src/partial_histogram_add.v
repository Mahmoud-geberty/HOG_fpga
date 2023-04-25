module partial_histogram_add #(
    parameter INPUT_BIN_WIDTH = 11,
    parameter OUTPUT_BIN_WIDTH = 14,
    parameter BINS         = 9,   // number of bins in each histogram
    parameter CELL_ROWS    = 8,   // number of rows per cell, number of partial histograms
    parameter INPUT_WIDTH  = INPUT_BIN_WIDTH * BINS * CELL_ROWS, 
    parameter OUTPUT_WIDTH = OUTPUT_BIN_WIDTH * BINS 
) (
    input [INPUT_WIDTH-1:0]   partial_histogram, // 8 partial histograms as 1 vector
    output [OUTPUT_WIDTH-1:0] full_histogram // one full histogram output
);

    // for now... number of pixel rows per cell must be 8
    initial begin 
        if (CELL_ROWS != 8) begin 
            $display("INSTANTIATION ERROR: Incorrect CELL_ROWS parameter, must be 8");
        end
    end

    genvar i; 
    generate
        for (i = 0; i < BINS; i = i + 1) begin : FULL_HISTOGRAM
            // the ith bin of the output is the sum of 
            // the ith bins of each row (partial histogram)
            // ** aware that this could be another loop, too lazy to change it...
            assign full_histogram[i*OUTPUT_BIN_WIDTH +: OUTPUT_BIN_WIDTH] = 
                partial_histogram[i*INPUT_BIN_WIDTH +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+99 +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+198 +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+297 +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+396 +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+495 +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+594 +: INPUT_BIN_WIDTH] + 
                partial_histogram[i*INPUT_BIN_WIDTH+693 +: INPUT_BIN_WIDTH];
        end
    endgenerate

endmodule