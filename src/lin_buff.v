/*
    Author: Mahmoud Abdelwase
    Date: 13/03/2023
    description: A generic line buffer implementation
    parameters: 
        BUFFER_WIDTH: buffer element's width in bits.
        BUFFER_DEPTH: buffer array length, used to determine address width.
        BLOCK_WIDTH:  number of buffer elements exposed for operations.
        BLOCK_HEIGHT: number of buffer rows (lines). 
*/

// TODO: handle ignoring the kernel between video frames, avoid a big counter
module lin_buff #(
    parameter BUFFER_WIDTH = 8,
    parameter BUFFER_DEPTH = 854, // default support for 480p images
    parameter BLOCK_WIDTH  = 3,
    parameter BLOCK_HEIGHT = 3,
    parameter OUTPUT_WIDTH = BLOCK_WIDTH * BLOCK_HEIGHT * BUFFER_WIDTH
)(
    input                     clk, rst,
    input                     p_valid, 
    input [BUFFER_WIDTH-1:0]  pixel,
    input                     k_ready,
    output                    p_ready, 
    output                    k_border,
    output                    k_valid,
    output [OUTPUT_WIDTH-1:0] kernel
);

    //concatenated kernel data I/O size in bits
    parameter K_DATA_WIDTH = BLOCK_HEIGHT * BUFFER_WIDTH;
    // kernel row size in bits
    parameter K_ROW_WIDTH = BLOCK_WIDTH * BUFFER_WIDTH;

    // state register constants
    parameter IDLE    = 0; // reset state
    parameter BUFFER  = 1; // wait for all buffers to fill
    parameter STREAM  = 2; // stream and operate on each kernel.

    // connective wires (buffer interface)
    wire                    f_to_k_valid;
    wire                    f_to_k_ready;
    wire [BUFFER_WIDTH-1:0] f_to_k_data;
    wire                    k_to_f_valid;
    wire                    k_to_f_ready;
    wire [BUFFER_WIDTH-1:0] k_to_f_data;
    wire                    b_to_k_valid [0:BLOCK_HEIGHT - 2];
    wire                    b_to_k_ready [0:BLOCK_HEIGHT - 2];
    wire [BUFFER_WIDTH-1:0] b_to_k_data  [0:BLOCK_HEIGHT - 2];
    wire                    k_to_b_valid [0:BLOCK_HEIGHT - 2];
    wire                    k_to_b_ready [0:BLOCK_HEIGHT - 2];
    wire [BUFFER_WIDTH-1:0] k_to_b_data  [0:BLOCK_HEIGHT - 2];

    // concatenated connective wires (kernel interface).
    // kernel data input signals      
    wire [BLOCK_HEIGHT-1:0] k_in_valid;
    wire [BLOCK_HEIGHT-1:0] k_in_ready; // output from kernel, 
    wire [K_DATA_WIDTH-1:0] k_in_data;

    // kernel data output signals 
    wire [BLOCK_HEIGHT-1:0] k_out_valid; 
    wire [BLOCK_HEIGHT-1:0] k_out_ready; // input to kernel.
    wire [OUTPUT_WIDTH-1:0] k_out_data; 
    
    // loop variable
    genvar j;

    // kernel input concatenation procedure
    // inputs to the first kernel row
    assign k_in_valid[0] = p_valid;
    assign p_ready = k_in_ready[0];
    assign k_in_data[0 +: BUFFER_WIDTH] = pixel;

    // inputs to second kernel row
    assign k_in_valid[1] = f_to_k_valid;
    assign f_to_k_ready = k_in_ready[1];
    assign k_in_data[BUFFER_WIDTH +: BUFFER_WIDTH] = f_to_k_data;

    // inputs to the rest of kernel rows
    generate
        for (j = 0; j < BLOCK_HEIGHT - 2; j = j + 1) begin:KERNEL_IN 
            assign k_in_valid[j+2] = b_to_k_valid[j];
            assign b_to_k_ready[j] = k_in_ready[j+2];
            assign k_in_data[(j+2)*BUFFER_WIDTH +: BUFFER_WIDTH]  = b_to_k_data[j];
        end
    endgenerate

    // kernel output concatenation procedure
    assign k_out_ready[BLOCK_HEIGHT-1] = k_ready;

    assign k_to_f_valid = k_out_valid[0]; 
    assign k_out_ready[0] = k_to_f_ready;
    assign k_to_f_data = k_out_data[0 +: BUFFER_WIDTH]; 

    generate
        for (j = 0; j < BLOCK_HEIGHT-2; j = j + 1) begin:KERNEL_OUT 
            assign k_to_b_valid[j] = k_out_valid[j+1]; 
            assign k_out_ready[j+1] = k_to_b_ready[j]; 
            assign k_to_b_data[j] = k_out_data[(j+1)*K_ROW_WIDTH +: BUFFER_WIDTH];
        end
    endgenerate

    assign kernel = k_out_data;

    // instantiate the kernel block
    kernel #(
        .DATA_WIDTH(BUFFER_WIDTH),
        .BLOCK_WIDTH(BLOCK_WIDTH), 
        .BLOCK_HEIGHT(BLOCK_HEIGHT)
    ) kernel_block (
        .clk(clk), .rst(rst), 
        .in_pixels(k_in_data), .out_pixels(k_out_data),
        .in_valid(k_in_valid), .in_ready(k_in_ready), 
        .out_valid(k_out_valid), .out_ready(k_out_ready),
        .kernel_valid(k_valid)
    );

    genvar i; 
    generate 

        custom_fifo #(
            .DATA_WIDTH(BUFFER_WIDTH), 
            .FIFO_DEPTH(BUFFER_DEPTH - BLOCK_WIDTH), 
            .KERNEL_WIDTH(BLOCK_WIDTH)
        ) first_line (
            .clk(clk), .rst(rst), 
            .w_data(k_to_f_data), .r_data(f_to_k_data),
            .w_valid(k_to_f_valid), .w_ready(k_to_f_ready),
            .r_valid(f_to_k_valid), .r_ready(f_to_k_ready), 
            .fifo_full(), .border_flag(k_border)
        ); 

        for (i = 0; i < BLOCK_HEIGHT-2; i = i + 1) begin:FIFO_BLK
            custom_fifo #(
                .DATA_WIDTH(BUFFER_WIDTH), 
                .FIFO_DEPTH(BUFFER_DEPTH - BLOCK_WIDTH), 
                .KERNEL_WIDTH(BLOCK_WIDTH)
            ) line_buff (
               .clk(clk), .rst(rst), 
               .w_data(k_to_b_data[i]), .r_data(b_to_k_data[i]),
               .w_valid(k_to_b_valid[i]), .w_ready(k_to_b_ready[i]),
               .r_valid(b_to_k_valid[i]), .r_ready(b_to_k_ready[i]), 
               .fifo_full(), .border_flag()
            ); 
        end
    endgenerate

endmodule