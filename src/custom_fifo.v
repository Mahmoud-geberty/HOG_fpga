/*
Author     : Mahmoud
date       : 17/03/2023
description: A custom fifo only used for line buffer implementation. Indicates illegal
             kernels (border cases), not meant to be read until it is full.  */

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
    reg                   r_valid_reg; 
    wire                  fifo_write; // memory port A write enable
    wire                  initial_read;

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

    // read states 
    parameter S_DISABLE = 0; 
    parameter S_FIRST_READ = 1; 
    parameter S_ADDR_CORRECTION = 2; 
    parameter S_NORMAL_READ = 3; 
    parameter S_PAUSE = 4; 

    reg [2:0] current_state, next_state; 

    always @(*) begin 
        next_state = current_state; 

        // Need a state to handle r_valid_reg going low coz of w_ready (next stage fifos)
        case (current_state)
            S_DISABLE: begin 
                if (fifo_full && fifo_write) begin
                    next_state = S_FIRST_READ; 
                end
            end
            S_FIRST_READ: begin 
                if (w_valid) begin 
                    next_state = S_ADDR_CORRECTION;
                end
            end
            S_ADDR_CORRECTION: begin 
                next_state = S_NORMAL_READ; 
            end
            S_NORMAL_READ: begin 
                if (!w_valid) begin 
                    next_state = S_PAUSE; 
                end
            end
            S_PAUSE: begin 
                if (w_valid) begin 
                    next_state = S_NORMAL_READ;
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
            read_enable <= 0; 
        end
        else if (fifo_full && fifo_write) begin 
            read_enable <= 1; 
        end
    end

    generate
        if (FIRST_LINE == 1) begin 
            always @(posedge clk, posedge rst) begin 
                if (rst) begin 
                    r_valid_reg <= 'd0; 
                end
                else if (~fifo_write) begin 
                    r_valid_reg <= 'd0; 
                end
                else if (read_enable) begin 
                    r_valid_reg <= 'd1; 
                end
            end
        end
        else begin 
            always @(posedge clk, posedge rst) begin 
                if (rst) begin 
                    r_valid_reg <= 'd0; 
                end
                else if (~fifo_write) begin 
                    r_valid_reg <= 'd0; 
                end
                else if (read_enable || (w_valid && w_ready && fifo_full)) begin 
                    r_valid_reg <= 'd1; 
                end
            end
        end
    endgenerate

    assign fifo_write = (w_valid && w_ready) || (w_valid && (next_state == S_ADDR_CORRECTION || next_state == S_NORMAL_READ));

    generate
        // can't receive a new word when the output destination is not ready
        // to read.
        if (FIRST_LINE == 1) begin 
            assign w_ready    = r_ready && (next_state != S_ADDR_CORRECTION) && current_state != S_PAUSE;
        end
        else begin 
            assign w_ready    = r_ready && current_state != S_PAUSE;
        end
    endgenerate

    // image edges are indicated by the first line buffer being full and the input
    // to it is being written at the addresses shown in the code.
    assign border_flag = fifo_full && (
              (w_addr == KERNEL_WIDTH - 1) || (w_addr == KERNEL_WIDTH)
            );

    // only read when the fifo is full and new data is about to be written
    assign r_valid = ~read_enable? fifo_full && fifo_write: r_valid_reg && w_valid;

    // assign r_addr_mux = (w_addr == FIFO_DEPTH-1)? 'd0: w_addr + 'd1;
    // assign r_addr = read_enable              ? w_addr : 
    //                 (fifo_full && fifo_write)? 'd1: 'd0;

    generate
        if (FIRST_LINE == 1) begin 
            assign r_addr = (current_state == S_DISABLE && next_state == S_FIRST_READ        )? 'd1:
                            (current_state == S_DISABLE                                      )? 'd0: 
                            (current_state == S_FIRST_READ && next_state == S_ADDR_CORRECTION)? 'd1: 
                            // (~r_valid_reg                                                    )? w_addr: 
                            (w_addr + 'd1  == FIFO_DEPTH                                     )? 'd0: w_addr + 'd1;
        end
        else begin 
            assign r_addr = (current_state == S_DISABLE && next_state == S_FIRST_READ        )? 'd1:
                            (current_state == S_DISABLE                                      )? 'd0: 
                            (w_addr + 'd1  == FIFO_DEPTH                                     )? 'd0: w_addr + 'd1;
        end
    endgenerate

    // instantiate a dual-port BRAM
    true_dual_port #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem (
        .clk(clk),
        .data_a(w_data), .data_b(),
        .addr_a(w_addr), .addr_b(r_addr),
        .we_a(fifo_write), .we_b(),
        .rd_a(), rd_b(read_mem),
        .q_a(), .q_b(r_data)
    );

endmodule
