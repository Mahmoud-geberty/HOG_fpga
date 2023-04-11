`timescale 1ns/1ns
module tb_norm_block(); 
    parameter IMAGE_WIDTH        = 64; // 640
    parameter IMAGE_HEIGHT       = 480;
    parameter CELL_ROW_PIXELS    = 8;
    parameter CELL_COLUMN_PIXELS = 8;
    parameter BLOCK_ROW_CELLS    = 2;
    parameter BLOCK_COLUMN_CELLS = 2;
    parameter BIN_WIDTH          = 14;
    parameter BINS               = 9; // 10th bin is the sum
    parameter HISTOGRAM_WIDTH    = BIN_WIDTH * (BINS+1);
    parameter CELLS_PER_BLOCK    = 4;
    parameter BLOCK_HIST_WIDTH   = HISTOGRAM_WIDTH * CELLS_PER_BLOCK;
    parameter OUTPUT_WIDTH       = BINS * CELLS_PER_BLOCK;


    reg                       clk, rst;
    reg                       in_valid, out_ready;
    reg [HISTOGRAM_WIDTH-1:0] cell_histogram;
    wire                      out_valid, in_ready;
    wire [OUTPUT_WIDTH-1:0]   normalized_block;


    wire [BINS-1:0]           normalized_2d [0:CELLS_PER_BLOCK-1];
    wire [BIN_WIDTH-1:0]      cell_histogram_2d [0: BINS];

    genvar i; 

    for (i = 0; i < CELLS_PER_BLOCK; i = i + 1) begin 
        assign normalized_2d[i] = normalized_block[i*BINS +: BINS];
    end

    for (i = 0; i <= BINS; i = i + 1) begin 
        assign cell_histogram_2d[i] = cell_histogram[i*BIN_WIDTH +: BIN_WIDTH];
    end

    norm_block #(
        .IMAGE_WIDTH        ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT       ( IMAGE_HEIGHT ),
        .CELL_ROW_PIXELS    ( CELL_ROW_PIXELS ),
        .CELL_COLUMN_PIXELS ( CELL_COLUMN_PIXELS ),
        .BLOCK_ROW_CELLS    ( BLOCK_ROW_CELLS ),
        .BLOCK_COLUMN_CELLS ( BLOCK_COLUMN_CELLS ),
        .BIN_WIDTH          ( BIN_WIDTH ),
        .BINS               ( BINS ),
        .CELLS_PER_BLOCK    ( CELLS_PER_BLOCK )
    ) dut (
        .clk                ( clk                ),
        .rst                ( rst                ),
        .in_valid           ( in_valid           ),
        .out_ready          ( out_ready          ),
        .cell_histogram     ( cell_histogram     ),
        .out_valid          ( out_valid          ),
        .in_ready           ( in_ready           ),
        .normalized_block   ( normalized_block   )
    );

    always #5 clk = ~clk; 

    initial begin
        clk = 0; 
        rst = 1;
        in_valid = 0;
        out_ready = 0; 
        cell_histogram = {
            $random, $random, $random, $random, $random
            };
        @(posedge clk);
        in_valid = 1; 
        out_ready = 1; 
        rst = 0; 

        repeat (20) begin 
            @(posedge clk); 
        end

        in_valid = 0; 
        repeat (10) begin 
            @(posedge clk); 
            cell_histogram = {
                $random, $random, $random, $random, $random
                };
        end
        in_valid = 1; 
        repeat (80) begin 
            @(posedge clk); 
            cell_histogram = {
                $random, $random, $random, $random, $random
                };
        end

        $stop;
    end

endmodule