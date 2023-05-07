`timescale 1ns/1ns
module tb_hog();

    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 32;
    parameter IMAGE_HEIGHT = 32; 
    parameter WINDOW_WIDTH = 32 * 36; 

    reg clk, rst;
    reg pixel_valid, window_ready; 
    reg [DATA_WIDTH-1:0] pixel;
    wire window_valid, pixel_ready;
    wire [WINDOW_WIDTH-1:0] detection_window; 

    hog#(
        .DATA_WIDTH   ( DATA_WIDTH ),
        .IMAGE_WIDTH  ( IMAGE_WIDTH ),
        .IMAGE_HEIGHT ( IMAGE_HEIGHT )
    )dut(
        .clk          ( clk          ),
        .rst          ( rst          ),
        .pixel_valid  ( pixel_valid  ),
        .window_ready ( window_ready ),
        .pixel        ( pixel        ),
        .window_valid ( window_valid ),
        .pixel_ready  ( pixel_ready  ),
        .detection_window  ( detection_window  )
    );

    always #5 clk = ~clk; 

    initial begin 
        clk = 0; 
        rst = 1; 
        pixel_valid = 0; 
        window_ready = 1; 
        pixel = 'd0; 

        repeat (900) begin 
            @(posedge clk);
            rst = 0; 
            pixel_valid = 1; 
            pixel = $random; 
        end

        $stop; 
    end

endmodule