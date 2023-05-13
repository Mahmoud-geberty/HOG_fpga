/*
Author     : Mahmoud
date       : 17/03/2023
description: A custom fifo only used for line buffer implementation. Indicates illegal
             kernels (border cases), not meant to be read until it is full.  */

// TODO: 1. fix the fifo and fully verify the correctness of the kernels
//       2. implement the border detection, this time factor the different kernel sizes

module custom_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 854,
    parameter KERNEL_WIDTH = 3,
    // boolean, is this fifo the first one in the line buffer?
    parameter FIRST_LINE = 0
) (
    input clk, rst,
    input [DATA_WIDTH-1:0]  w_data,
    input                   w_valid,
    input                   r_ready,
    output [DATA_WIDTH-1:0] r_data,
    output                  r_valid,
    output                  w_ready,
    output reg              fifo_full,
    // indicate the kernel is at the border and no operation is to be performed
    output                  border_flag
);

    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // internal signals
    reg [ADDR_WIDTH-1: 0] w_addr;
    wire [ADDR_WIDTH-1:0] r_addr;
    wire                  read_mem; 
    // wire [ADDR_WIDTH-1:0] r_addr_mux;
    reg                   read_enable; 
    reg [ADDR_WIDTH-1:0]  read_offset; 
    wire                  fifo_write; // memory port A write enable

    // write address logic
    // increment whenever data is written, w_addr is a mod(fifo_depth) counter.
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin 
            w_addr <= 0;
        end
        else if (w_valid && w_ready && w_addr == FIFO_DEPTH-1) begin 
            w_addr <= 0;
        end
        else if (w_valid && w_ready) begin
            w_addr <= w_addr + 1;
        end
    end

    // fifo_full indicator
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            fifo_full <= 0;
        end
        else if (w_valid && w_ready && w_addr == FIFO_DEPTH-1) begin
            fifo_full <= 1;
        end
    end

    assign fifo_write = w_valid && w_ready; 

    // read state machine 
    parameter S_DISABLE = 0; // waiting for the fifo to be full
    parameter S_READ    = 1; // fifo is full and read is enabled
    parameter S_PAUSE   = 2; // backpressure

    reg [1:0] current_state, next_state; 

    always @(*) begin 
        next_state = current_state; 

        case (current_state)
            S_DISABLE: begin 
                if (fifo_full && w_valid ) begin 
                    next_state = S_READ;
                end
            end
            S_READ: begin 
                if (!w_valid ) begin 
                    next_state = S_PAUSE; 
                end
            end
            S_PAUSE: begin 
                if (w_valid) begin 
                    next_state = S_READ; 
                end
            end
            default: next_state = current_state; 
        endcase
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            current_state <= S_DISABLE;
        end
        else begin 
            current_state <= next_state; 
        end
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            read_offset <= 0; 
        end
        else if (next_state == S_READ && current_state != S_READ && read_offset != FIFO_DEPTH-1) begin 
            read_offset <= read_offset + 'd1; 
        end
    end

    generate
        if (FIRST_LINE == 1) begin 
            assign w_ready = r_ready && !(next_state == S_READ && current_state != S_READ); 
        end
        else begin 
            // assign w_ready = r_ready; 
            assign w_ready = r_ready && !(next_state == S_READ && current_state != S_READ); 
        end
    endgenerate

    assign read_mem = (current_state == S_READ || next_state == S_READ) ;
    // gating r_valid seems to cause a combinational loop, simulation runs till timeout
    assign r_valid  = current_state == S_READ; 
    assign r_addr   = w_addr + read_offset >= FIFO_DEPTH ? (w_addr + read_offset) - FIFO_DEPTH : w_addr + read_offset; // addr offset

    assign border_flag = 'd0; 

    // instantiate a dual-port BRAM
    true_dual_port #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem (
        .clk(clk),
        .data_a(w_data), .data_b(),
        .addr_a(w_addr), .addr_b(r_addr),
        .we_a(fifo_write), .we_b(),
        .rd_a(), .rd_b(read_mem),
        .q_a(), .q_b(r_data)
    );

endmodule
