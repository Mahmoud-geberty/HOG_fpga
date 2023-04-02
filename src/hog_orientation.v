module hog_orientation #(
    parameter DATA_WIDTH = 8
) (
    input [DATA_WIDTH-1:0]  gx, gy,
    input                   is_upper_bin,
    output [3:0]            bin_out
); 

    // these values are already left-shifted by 10
    localparam TAN20 = 373; // 372.706
    localparam TAN40 = 859; // 859.238
    localparam TAN60 = 1774; // 1773.620
    localparam TAN80 = 5807; // 5807.393

    wire [20:0] gx_prod20, gx_prod40, gx_prod60, gx_prod80; 
    wire [20:0] gy_shifted;
    reg [3:0]  bin;

    assign gy_shifted = gy << 10;
    assign gx_prod20 = gx * TAN20;
    assign gx_prod40 = gx * TAN40; 
    assign gx_prod60 = gx * TAN60;
    assign gx_prod80 = gx * TAN80; 

    always @(*) begin 

        if (gy_shifted < gx_prod20) begin 
            bin = 0; 
        end
        else if (gy_shifted < gx_prod40) begin 
            bin = 1;
        end
        else if (gy_shifted < gx_prod60) begin 
            bin = 2; 
        end
        else if (gy_shifted < gx_prod80) begin 
            bin = 3; 
        end
        else begin 
            bin = 4; 
        end
    end

    assign bin_out = is_upper_bin? 8-bin : bin; 

endmodule