//3. Find the skip count value for each scale and how it changes in levels.
//- 1.10(mod9),1.15(6),1.2(5),1.25(4),1.3(3),1.35(2),1.40(2),1.45(2),1.5(1)
module downsample #(
    parameter SCALE = 9
)(
    input clk, rst, 
    input in_valid, out_ready, 
    output out_valid, in_ready
); 

    localparam PIXEL_CNT_WIDTH = $clog2(SCALE); 

    reg [PIXEL_CNT_WIDTH-1:0] pixel_cnt; 

    assign in_ready = out_ready; 
    assign out_valid = in_valid && (pixel_cnt != SCALE);

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            pixel_cnt <= 0; 
        end
        else if (in_valid && in_ready && pixel_cnt == SCALE) begin
            pixel_cnt <= 0; 
        end
        else if (in_valid && in_ready) begin 
            pixel_cnt <= pixel_cnt + 1; 
        end
    end

endmodule