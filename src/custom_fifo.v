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

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // internal signals
    reg [ADDR_WIDTH-1: 0] w_addr;
    reg [ADDR_WIDTH-1: 0] r_addr;
    reg                   read_mem; 
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
    localparam S_DISABLE     = 0; // waiting for the fifo to be full
    localparam S_READ        = 1; // fifo is full and read is enabled
    localparam S_PAUSE       = 2; // backpressure due to in_valid or in_ready deassertion

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
                if (!w_valid || !w_ready) begin 
                    next_state = S_PAUSE; 
                end
            end
            S_PAUSE: begin 
                if (w_valid && w_ready) begin 
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

    // expected to increment once only at the start of the read operation
    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            read_offset <= 0; 
        end
        else if ((current_state == S_DISABLE && next_state == S_READ) ) begin 
            read_offset <= read_offset + 'd1; 
        end
    end

    assign w_ready = r_ready ;
    assign r_valid  = next_state == S_READ ;//&& (next_state == S_READ); 

    // read_mem procedure
    always @(*) begin 
        read_mem = 1'd1; 

        if (current_state == S_READ && next_state == S_PAUSE) begin 
            read_mem = 1'd0; 
        end

        if (current_state == S_PAUSE && next_state != S_READ) begin 
            read_mem = 1'd0; 
        end

    end

    always @(*) begin 
        if (w_addr + read_offset >= FIFO_DEPTH) begin
            r_addr = (w_addr + read_offset) - FIFO_DEPTH; 
        end
        else begin 
            r_addr = w_addr + read_offset; 
        end

        if ((current_state == S_DISABLE && next_state == S_READ) ) begin 
            if (w_addr + read_offset + 'd1 >= FIFO_DEPTH) begin 
                r_addr = (w_addr + read_offset + 'd1) - FIFO_DEPTH;
            end
            else begin 
                r_addr  = w_addr + read_offset + 'd1; 
            end
        end
        else if (current_state == S_DISABLE) begin 
            r_addr = 'd0;
        end
    end

    // border detection
    localparam BORDER_COUNTER_MAX = KERNEL_WIDTH - 2; 
    localparam BORDER_COUNTER_SIZE = $clog2(BORDER_COUNTER_MAX); 

    reg                           border_active;
    reg                           border_skip; // indicates skipping border condition
    // counter is bigger than it needs to be... to avoid a declaration of [-1:0]
    reg [BORDER_COUNTER_SIZE:0]   border_cnt;  // border delay while asserted.
    reg [ADDR_WIDTH-1:0]          border_start_addr; 


    always @(posedge clk, posedge rst) begin
        if (rst) begin 
            border_start_addr <= KERNEL_WIDTH; 
        end
        else if (border_active && border_cnt == BORDER_COUNTER_MAX && w_valid && w_ready) begin 
            if ((border_start_addr + KERNEL_WIDTH) >= FIFO_DEPTH) begin 
                border_start_addr <= (border_start_addr + KERNEL_WIDTH) - FIFO_DEPTH; 
            end
            else begin 
                border_start_addr <= border_start_addr + KERNEL_WIDTH; 
            end
        end
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            border_skip <= 'd0; 
        end
        else if (w_addr == border_start_addr && current_state != S_DISABLE && w_valid && w_ready) begin 
            border_skip <= ~border_skip; 
        end
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            border_active <= 'd0; 
        end
        else if (border_cnt == BORDER_COUNTER_MAX && w_valid && w_ready ) begin 
            border_active <= 'd0; 
        end
        else if (w_addr == border_start_addr && border_skip && w_valid && w_ready) begin 
            border_active <= 'd1;
        end
    end

    always @(posedge clk, posedge rst ) begin 
        if (rst) begin 
            border_cnt <= 'd0; 
        end
        else if (border_cnt == BORDER_COUNTER_MAX && w_valid && w_ready) begin 
            border_cnt <= 'd0;
        end
        else if (border_active && w_valid && w_ready) begin 
            border_cnt <= border_cnt +'d1; 
        end
    end

    assign border_flag = border_active; 

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
