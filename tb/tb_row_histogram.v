`timescale 1ns/1ns
module tb_row_histogram(); 
    parameter DATA_WIDTH = 8;
    parameter BIN_WIDTH = 11;
    parameter HISTOGRAM_WIDTH = BIN_WIDTH * 9;

    reg                            clk, rst;
    reg                            in_valid, out_ready;
    reg [DATA_WIDTH-1:0]           magnitude;
    reg [3:0]                      bin_index;
    wire                           out_valid, in_ready;
    wire [HISTOGRAM_WIDTH-1:0]     row_histogram; 

    reg [2:0]                      bin_3bit;
    wire [BIN_WIDTH-1:0] histogram_2d [0:8];

    genvar i; 
    for (i = 0; i < 9; i = i + 1) begin 
        assign histogram_2d[i] = row_histogram[i*BIN_WIDTH +: BIN_WIDTH];
    end

    row_histogram #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .BIN_WIDTH  ( BIN_WIDTH )
    ) dut (
        .clk        ( clk        ),
        .rst        ( rst        ),
        .in_valid   ( in_valid   ),
        .out_ready  ( out_ready  ),
        .magnitude  ( magnitude  ),
        .bin_index  ( bin_index  ),
        .out_valid  ( out_valid  ),
        .in_ready   ( in_ready   ),
        .row_histogram  ( row_histogram  )
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

