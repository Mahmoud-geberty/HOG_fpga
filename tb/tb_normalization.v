`timescale 1ns/1ns
module tb_normalization (); 
    parameter BIN_WIDTH       = 14;
    parameter BINS            = 9; // 10th bin is the sum
    parameter CELLS_PER_BLOCK = 4; 
    parameter PIXELS_PER_CELL = 64; 
    parameter INPUT_WIDTH     = BIN_WIDTH * (BINS+1) * CELLS_PER_BLOCK;
    parameter OUTPUT_WIDTH    = BINS * CELLS_PER_BLOCK; // 1 bit per bin

    reg                     in_valid; // gate the circuit to save power
    reg [INPUT_WIDTH-1:0]   block_histograms;
    wire [OUTPUT_WIDTH-1:0] normalized_block; 

    wire [BIN_WIDTH-1:0] block_histograms_3d [0:CELLS_PER_BLOCK-1][0:BINS];
    wire [BINS-1:0]      normalized_2d [0:CELLS_PER_BLOCK-1];

    genvar i,j; 

    for (i = 0; i < CELLS_PER_BLOCK; i = i + 1) begin 
        for (j = 0; j <= BINS; j = j + 1) begin 
            assign block_histograms_3d[i][j] = 
                block_histograms[i*(BINS+1)*BIN_WIDTH + j*BIN_WIDTH +: BIN_WIDTH];
        end
    end

    for (i = 0; i < CELLS_PER_BLOCK; i = i + 1) begin 
        assign normalized_2d[i] = normalized_block[i*BINS +: BINS];
    end



    normalization#(
        .BIN_WIDTH        ( BIN_WIDTH ),
        .BINS             ( BINS ),
        .CELLS_PER_BLOCK  ( CELLS_PER_BLOCK ),
        .PIXELS_PER_CELL  ( PIXELS_PER_CELL )
    )dut(
        .in_valid         ( in_valid         ),
        .block_histograms ( block_histograms ),
        .normalized_block  ( normalized_block  )
    );

    initial begin
        in_valid = 0;
        block_histograms = {
            $random, $random, $random, $random, $random,
            $random, $random, $random, $random, $random,
            $random, $random, $random, $random, $random,
            $random, $random, $random, $random, $random,
            $random, $random, $random, $random, $random
            };
        #10 in_valid = 1; 

        repeat (20) begin 
            #10; 
        end

        in_valid = 0; 
        repeat (10) begin 
            #10; 
            block_histograms = {
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random
                };
        end
        in_valid = 1; 
        repeat (20) begin 
            #10; 
            block_histograms = {
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random
                };
        end

        $stop;
    end
endmodule