`timescale 1ns/1ns
module tb_custom_fifo(); 
    parameter DATA_WIDTH = 8; 

    reg clk, rst; 
    reg [DATA_WIDTH-1:0]  w_data; 
    reg                   w_valid; 
    reg                   r_ready; 
    wire [DATA_WIDTH-1:0] r_data; 
    wire                  r_valid; 
    wire                  w_ready; 
    wire                  fifo_full; 
    wire                  border_flag; 

    always #10 clk = ~clk;

    // dut
    custom_fifo #(
        .DATA_WIDTH(8), .FIFO_DEPTH(9)
    ) dut (
        .clk(clk), .rst(rst), 
        .w_data(w_data), .r_data(r_data), 
        .w_valid(w_valid), .r_ready(r_ready),
        .r_valid(r_valid), .w_ready(w_ready),
        .fifo_full(fifo_full), .border_flag(border_flag)
    ); 

    initial begin 
        clk = 0; 
        rst = 1; 
        repeat(2) @(posedge clk); 
        rst = 0; 
        w_valid = 1; 
        r_ready = 1; 
        w_data = $random;
        
        repeat(100) begin 
            @(posedge clk); 
            w_data = $random;
        end 
    end

    // test back-pressure behaviour
    initial begin 
        repeat(10) @(posedge clk);
        r_ready = 0; 
        repeat(5) @(posedge clk);
        r_ready = 1; 
        w_valid = 0; 
        repeat(5) @(posedge clk);
        w_valid = 1; 
        repeat(50) @(posedge clk);
        $finish();
    end
endmodule