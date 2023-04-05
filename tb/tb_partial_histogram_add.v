`timescale 1ns/1ns
module tb_partial_histogram_add();
    parameter INPUT_BIN_WIDTH  = 11;
    parameter OUTPUT_BIN_WIDTH = 14;
    parameter BINS             = 9;   // number of bins in each histogram
    parameter CELL_ROWS        = 8;
    parameter INPUT_WIDTH      = INPUT_BIN_WIDTH * BINS * CELL_ROWS;
    parameter OUTPUT_WIDTH     = OUTPUT_BIN_WIDTH * BINS; 

    reg [INPUT_WIDTH-1:0]   partial_histogram; // 8 partial histograms as 1 vector
    wire [OUTPUT_WIDTH-1:0] full_histogram;  // one full histogram output

    wire [INPUT_BIN_WIDTH-1:0] partial_histogram_3d [0:CELL_ROWS-1][0:BINS-1]; 
    wire [OUTPUT_BIN_WIDTH-1:0] full_histogram_2d [0:BINS-1]; 

    genvar i, j; 
    for (i = 0; i < BINS; i = i + 1) begin 
        assign full_histogram_2d[i] = full_histogram[i*OUTPUT_BIN_WIDTH +: OUTPUT_BIN_WIDTH]; 
    end

    for (i = 0; i < CELL_ROWS; i = i + 1 ) begin 
        for (j = 0; j < BINS; j = j + 1) begin 
            assign partial_histogram_3d[i][j] = partial_histogram[(i*99)+(j*11) +: 11];
        end
    end

    partial_histogram_add#(
        .INPUT_BIN_WIDTH   ( INPUT_BIN_WIDTH ),
        .OUTPUT_BIN_WIDTH  ( OUTPUT_BIN_WIDTH ),
        .BINS              ( BINS )
    )dut(
        .partial_histogram ( partial_histogram ),
        .full_histogram    ( full_histogram    )
    );

    initial begin 
        repeat(30) begin 
            partial_histogram = {
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random,
                $random, $random, $random, $random, $random
                }; 
            #5;
        end
        $display("row8 bin9 => 3D[7][8]= %d", partial_histogram_3d[7][8]);
        $finish;
    end
endmodule