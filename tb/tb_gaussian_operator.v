`timescale 1ns/1ns
module tb_gaussian_operator(); 
    parameter DATA_WIDTH = 8;
    parameter KERNEL_WIDTH = 3 * 3 * DATA_WIDTH;

    reg                    in_valid, out_ready;
    reg [KERNEL_WIDTH-1:0] kernel;
    wire                   out_valid, in_ready;
    wire [DATA_WIDTH-1:0]  data_out;

    wire [DATA_WIDTH-1:0] kernel_2d [0:8]; 

    genvar i; 
    for (i = 0; i < 9; i = i + 1) begin 
        assign kernel_2d[i] = kernel[i*DATA_WIDTH +: DATA_WIDTH]; 
    end


    gaussian_operator#(
        .DATA_WIDTH ( DATA_WIDTH )
    )dut(
        .in_valid   ( in_valid   ),
        .out_ready  ( out_ready  ),
        .kernel     ( kernel     ),
        .out_valid  ( out_valid  ),
        .in_ready   ( in_ready   ),
        .data_out   ( data_out   )
    );

    initial begin 
        in_valid = 0; 
        out_ready = 0; 
        kernel = 0; 

        #10 in_valid = 1; 
        out_ready = 1; 

        repeat(50) begin 
            #10; 
            kernel = {$random, $random, $random, $random}; 
        end

        $stop; 
    end

endmodule