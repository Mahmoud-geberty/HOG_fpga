// a binarized normalization. 
// takes a concatenated block representing 4 histograms, 
// and produces the binarized and normalized content of the histograms

module normalization #(
    parameter BIN_WIDTH       = 14, 
    parameter BINS            = 9, // 10th bin is the sum
    parameter CELLS_PER_BLOCK = 4, 
    parameter INPUT_WIDTH     = BIN_WIDTH * (BINS+1) * CELLS_PER_BLOCK, 
    parameter OUTPUT_WIDTH    = BINS * CELLS_PER_BLOCK // 1 bit per bin
) (
    input                     in_valid, // gate the circuit to save power
    input                     k_border,
    input [INPUT_WIDTH-1:0]   block_histograms, 
    output                    out_valid,
    output [OUTPUT_WIDTH-1:0] normalized_block 
);

    reg [15:0] sum; 
    wire [11:0] shifted_sum;

    assign out_valid = in_valid && !k_border;

    genvar i,j; 
    integer k; 

    always @(*) begin 
        sum = 0; 
        for (k = 0; k < CELLS_PER_BLOCK; k = k + 1) begin 
            sum = 
                in_valid? sum + block_histograms[(k*(BINS+1)+BINS)*BIN_WIDTH +: BIN_WIDTH] : 0;
        end
    end

    assign shifted_sum = sum >> 4; 

    generate
        for (i = 0; i < BINS; i = i + 1) begin : NORM_BLOCK_BINS
            for (j = 0; j < CELLS_PER_BLOCK; j = j + 1) begin : NORM_BLOCK_CELLS
                assign normalized_block[i + j*9] = 
                    (block_histograms[i*BIN_WIDTH + j*10*BIN_WIDTH +: BIN_WIDTH] >= shifted_sum); 
            end
        end
    endgenerate

endmodule