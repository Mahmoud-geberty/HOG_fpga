`timescale 1ns/1ns
module tb_hog_gradient();

    parameter KERNEL_WIDTH = 72;

    reg                       clk, rst;
    reg                       k_valid;  
    reg                       out_ready;
    reg [KERNEL_WIDTH-1: 0]   kernel;
    wire                      k_ready;
    wire                      out_valid;
    wire  [8:0]               Gx, Gy;   

    wire  [7:0] kernel_2d [0:8];

    genvar i; 

    for (i = 0; i < 9; i = i + 1) begin 
        assign kernel_2d[i] = kernel[i*8 +: 8];
    end

    hog_gradient#(
        .KERNEL_WIDTH ( 72 )
    ) dut (
        .clk       ( clk     ),
        .rst       ( rst     ),
        .k_valid   ( k_valid ),
        .out_ready ( out_ready ),
        .kernel    ( kernel  ),
        .k_ready   ( k_ready ),
        .out_valid ( out_valid ),
        .Gx        ( Gx      ),
        .Gy        ( Gy      )
    );

    always #5 clk = ~clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        k_valid = 0;
        kernel = 0; 
        out_ready = 1;

        @(posedge clk); 
        k_valid = 1; 
        rst = 0; 
        kernel = {$random,$random};

        repeat(20) begin 
            @(posedge clk);
            kernel = {$random,$random};
        end

        k_valid = 0; 
        out_ready = 0;
        repeat(2) @(posedge clk);
        out_ready = 1;

        repeat(20) begin 
            @(posedge clk);
            kernel = {$random,$random};
        end
        k_valid = 1; 
        repeat(20) begin 
            @(posedge clk);
            kernel = {$random,$random};
        end

        $finish();
    end

endmodule