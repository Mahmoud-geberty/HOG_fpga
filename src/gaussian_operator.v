module gaussian_operator #(
    parameter DATA_WIDTH = 8, 
    parameter KERNEL_WIDTH = 3,
    parameter KERNEL_HEIGHT = 3, 
    parameter INPUT_WIDTH = DATA_WIDTH * KERNEL_WIDTH * KERNEL_HEIGHT 
) (
    input                    in_valid, out_ready, 
    input [INPUT_WIDTH-1:0]  kernel,
    output                   out_valid, in_ready, 
    output [DATA_WIDTH-1:0]  data_out
); 

    assign in_ready = out_ready; 
    assign out_valid = in_valid;
    assign data_out = (kernel[0+:DATA_WIDTH] >> 4) + 
                      (kernel[DATA_WIDTH+:DATA_WIDTH] >> 3) + 
                      (kernel[2*DATA_WIDTH+:DATA_WIDTH] >> 4) + 
                      (kernel[3*DATA_WIDTH+:DATA_WIDTH] >> 3) + 
                      (kernel[4*DATA_WIDTH+:DATA_WIDTH] >> 2) + 
                      (kernel[5*DATA_WIDTH+:DATA_WIDTH] >> 3) + 
                      (kernel[6*DATA_WIDTH+:DATA_WIDTH] >> 4) + 
                      (kernel[7*DATA_WIDTH+:DATA_WIDTH] >> 3) + 
                      (kernel[8*DATA_WIDTH+:DATA_WIDTH] >> 4);
endmodule