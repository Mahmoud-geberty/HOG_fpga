`timescale 1ns/1ns
module tb_hog_orientation (); 
    parameter DATA_WIDTH = 8;

    reg [DATA_WIDTH-1:0]  gx, gy;
    reg                   is_upper_bin;
    wire [3:0]            bin_out;

    hog_orientation#(
        .DATA_WIDTH   ( 8 )
    )dut(
        .gx           ( gx           ),
        .gy           ( gy           ),
        .is_upper_bin ( is_upper_bin ),
        .bin_out      ( bin_out      )
    );

    // TODO: verify this
    initial begin 
        repeat(20) begin 
            #10; 
            gx = $random;
            gy = $random; 
            is_upper_bin = $random;
        end
    end


endmodule