`timescale 1ns/1ns
module tb_hog_magnitude(); 
    parameter DATA_WIDTH = 8;

    reg [DATA_WIDTH-1:0] gx, gy;
    wire [DATA_WIDTH-1:0] magnitude;


    hog_magnitude#(
        .DATA_WIDTH ( DATA_WIDTH )
    )dut(
        .gx ( gx ),
        .gy ( gy ),
        .magnitude  ( magnitude  )
    );

    
    initial begin
        repeat(20) begin 
            #10;
            gx = $random;
            gy = $random;
        end
        $stop;
    end

endmodule