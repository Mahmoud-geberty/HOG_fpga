module abs #(
    parameter DATA_WIDTH = 8
) (
    input [DATA_WIDTH:0]    data_in1, data_in2,
    output                  is_upper_bin,
    output [DATA_WIDTH-1:0] data_out1, data_out2
);

    wire input_sign1, input_sign2;
    // assign the input MSBs as sign bits
    assign input_sign1 = data_in1[DATA_WIDTH];
    assign input_sign2 = data_in2[DATA_WIDTH];

    // the orientation is in bins >4 when signs are different
    // in other words the angle between the 2 gradients is >90
    assign is_upper_bin = input_sign1 != input_sign2;

    assign data_out1 = input_sign1? ~data_in1 + 1 : data_in1[DATA_WIDTH-1:0];
    assign data_out2 = input_sign2? ~data_in2 + 1 : data_in2[DATA_WIDTH-1:0];

endmodule