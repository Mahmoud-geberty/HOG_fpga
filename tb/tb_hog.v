`timescale 1ns/1ns
module tb_hog();

    parameter DATA_WIDTH = 8;
    parameter IMAGE_WIDTH = 128;
    parameter IMAGE_HEIGHT = 256; 
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

    // make it 10 MHz to mimick the real clock
    always #50 clk = ~clk; 

    reg start, ending; 
    reg start_time, end_time;
    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            start = 0; 
            ending = 0; 
        end
        else if (window_valid && window_ready && !ending) begin 
            ending = 1; 
            end_time = $time; 
        end
        else if (pixel_valid && pixel_ready) begin 
            if (!start) begin 
                start = 1;
                start_time = $time; 
            end
        end
    end


    initial begin 
        $monitor ($time, " system_latency = end_time (%d) - start_time (%d) = %d", end_time, start_time, end_time-start_time); 
        start = 0;
        clk = 0; 
        rst = 1; 
        pixel_valid = 0; 
        window_ready = 1; 
        pixel = 'd0; 

        repeat (9000) begin 
            @(posedge clk);
            rst = 0; 
            pixel_valid = 1; 
            pixel = $random; 
        end

        $stop; 
    end

endmodule