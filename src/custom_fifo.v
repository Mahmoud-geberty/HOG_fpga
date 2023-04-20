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
    parameter FIRST_LINE = 1
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
  reg [ADDR_WIDTH-1: 0] w_addr,  r_addr_reg;
  wire [ADDR_WIDTH-1:0] r_addr;
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

  assign fifo_write = w_valid && w_ready;

  // icrement r_addr for the first time when the fifo gets filled.
  assign initial_read = w_valid && w_ready && w_addr == FIFO_DEPTH-1;

  // can't receive a new word when the output destination is not ready
  // to read.
  assign w_ready    = r_ready;

  // image edges are indicated by the first line buffer being full and the input
  // to it is being written at the addresses shown in the code.
  assign border_flag = fifo_full && (
           (w_addr == KERNEL_WIDTH - 1) || (w_addr == KERNEL_WIDTH)
         );


  // read address logic
  // Aside from the initial increment, the r_addr only increments
  // after the data is successfully read. r_addr is mod(fifo_depth) counter.
  always @(posedge clk, posedge rst)
  begin
    if (rst) begin
      r_addr_reg <= 0;
    end
    else if (r_valid && r_ready && r_addr == FIFO_DEPTH - 1) begin
      r_addr_reg <= 0;
    end
    // else if ( (r_valid && r_ready) || (initial_read && r_ready)) begin
    else if ( (r_valid && r_ready) ) begin
      r_addr_reg <= r_addr_reg + 1;
    end
  end

  // only read when the fifo is full and new data is about to be written
  assign r_valid = fifo_full && fifo_write;
  assign r_addr = (r_valid && r_addr_reg != FIFO_DEPTH-1)? r_addr_reg + 1: r_addr_reg;

  // instantiate a dual-port BRAM
  true_dual_port #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) mem (
    .clk(clk),
    .data_a(w_data), .data_b(),
    .addr_a(w_addr), .addr_b(r_addr),
    .we_a(fifo_write), .we_b(),
    .q_a(), .q_b(r_data)
  );

endmodule
