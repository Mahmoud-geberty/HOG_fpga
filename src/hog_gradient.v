/*
    description: takes a 3x3 kernel every cycle and outputs its 
                 x and y gradients (Gx and Gy)
*/
module hog_gradient #(
    parameter KERNEL_WIDTH = 72 // 9 pixels * 8 bits/pixels = 72 bits
) (
    input                     clk, rst, 
    input                     k_valid, // deasserted for border cases
    input                     out_ready,
    input [KERNEL_WIDTH-1: 0] kernel,
    output                    k_ready,
    output reg                out_valid,
    output reg [8:0]          Gx, Gy   // signed values
); 

    assign k_ready = out_ready;

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            Gx <= 0; 
            Gy <= 0; 
        end
        else if (k_valid && k_ready) begin
            Gx <= kernel[40 +: 8] - kernel[24 +: 8]; 
            Gy <= kernel[8  +: 8] - kernel[56 +: 8]; 
        end
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            out_valid <= 1'd0;
        end
        else if (k_valid) begin 
            out_valid <= 1'd1;
        end
        else if (!k_valid && (out_valid && out_ready)) begin 
            out_valid <= 1'd0;
        end
    end
endmodule