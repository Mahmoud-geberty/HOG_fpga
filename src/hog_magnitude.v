module hog_magnitude #(
    parameter DATA_WIDTH = 8
) (
    input [DATA_WIDTH-1:0] gx, gy, 
    output [DATA_WIDTH-1:0] magnitude 
);

    assign magnitude = (gx >= gy)? gx - gy : gy - gx;

endmodule