`timescale 1ns/1ns
module tb_abs(); 
    parameter DATA_WIDTH = 8;

    reg [DATA_WIDTH:0]    data_in1, data_in2;
    wire                  is_upper_bin;
    wire [DATA_WIDTH-1:0] data_out1, data_out2;

abs #(
    .DATA_WIDTH   ( 8 )
) dut (
    .data_in1     ( data_in1     ),
    .data_in2     ( data_in2     ),
    .is_upper_bin ( is_upper_bin ),
    .data_out1    ( data_out1    ),
    .data_out2    ( data_out2    )
);

initial begin 
    repeat(20) begin 
        #10; 
        data_in1 = $random;
        data_in2 = $random;
    end
    $finish;
end
endmodule