`timescale 1ns/1ns
module tb_cell_histogram (); 
    parameter DATA_WIDTH       = 8;
    parameter IMAGE_WIDTH      = 640;
    parameter INPUT_BIN_WIDTH  = 11;
    parameter OUTPUT_BIN_WIDTH = 14;
    parameter HISTOGRAM_WIDTH  = OUTPUT_BIN_WIDTH * 9;

    reg                        clk, rst;
    reg                        in_valid, out_ready;
    reg [DATA_WIDTH-1:0]       magnitude;
    reg [3:0]                  bin_index;
    wire                       out_valid, in_ready;
    wire [HISTOGRAM_WIDTH-1:0] full_histogram;

    reg [2:0] bin_3bit;

    cell_histogram#(
        .DATA_WIDTH       ( DATA_WIDTH ),
        .IMAGE_WIDTH      ( IMAGE_WIDTH ),
        .INPUT_BIN_WIDTH  ( INPUT_BIN_WIDTH ),
        .OUTPUT_BIN_WIDTH ( OUTPUT_BIN_WIDTH )
    )dut(
        .clk              ( clk              ),
        .rst              ( rst              ),
        .in_valid         ( in_valid         ),
        .out_ready        ( out_ready        ),
        .magnitude        ( magnitude        ),
        .bin_index        ( bin_index        ),
        .out_valid        ( out_valid        ),
        .in_ready         ( in_ready         ),
        .full_histogram   ( full_histogram   )
    );

    always #5 clk = ~clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        out_ready = 1; 
        in_valid = 0; 
        magnitude = 0; 
        bin_index = 0; 

        #1 repeat(5) @(posedge clk);
        rst = 0; 
        in_valid = 1; 
        out_ready = 0; 
        bin_3bit = $random;
        bin_index = bin_3bit; 
        magnitude = $random; 

        repeat (25) begin 
            @(posedge clk); 
            bin_3bit = $random;
            bin_index = bin_3bit + 1; 
            magnitude = $random; 
        end

        out_ready = 1; 

        repeat (25) begin 
            @(posedge clk); 
            bin_3bit = $random;
            bin_index = bin_3bit ; 
            magnitude = $random; 
        end
        in_valid = 0; 
        repeat (15) begin 
            @(posedge clk); 
            bin_3bit = $random;
            bin_index = bin_3bit + 1; 
            magnitude = $random; 
        end
        in_valid = 1; 
        repeat (25) begin 
            @(posedge clk); 
            bin_3bit = $random;
            bin_index = bin_3bit ; 
            magnitude = $random; 
        end
        $stop; 
    end

endmodule