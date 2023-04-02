module kernel_shiftreg #(
    parameter DATA_WIDTH = 8,
    parameter BLOCK_WIDTH = 3,
    parameter OUTPUT_WIDTH = DATA_WIDTH * BLOCK_WIDTH
)(
    input                         clk, rst, 
    input [DATA_WIDTH-1:0]        in_data,
    input                         in_valid,
    input                         out_ready,
    output reg [OUTPUT_WIDTH-1:0] out_data,
    output                        in_ready,
    output                        out_valid
); 

    parameter BUFF_SIZE = $clog2(BLOCK_WIDTH);

    parameter S_IDLE = 0; // initial (reset) state
    parameter S_BUFFER = 1; // shift in 
    parameter S_STREAM = 2; // shift in and out  

    reg [1:0] current_state, next_state; 

    reg [BUFF_SIZE-1:0] buff_cnt;

    // state transitions
    always @(*) begin
        next_state = current_state; 

        case (current_state)
            S_IDLE: begin
                if (in_ready && in_valid) begin
                    next_state = S_BUFFER;
                end
            end
            S_BUFFER: begin
                if (buff_cnt == BLOCK_WIDTH - 2) begin 
                    next_state = S_STREAM;
                end
            end
            // stay at "stream" state until reset
        endcase
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            current_state <= S_IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            buff_cnt <= 0; 
        end
        else if (current_state == S_BUFFER && in_valid && in_ready) begin 
            buff_cnt <= buff_cnt + 1;  
        end
    end

    // OUTPUT LOGIC  

    // handshake outputs
    assign out_valid = in_valid && current_state == S_STREAM; 
    assign in_ready = out_ready; 

    // 2D shifting behavior
    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            out_data <= 0; 
        end
        else if (in_valid && in_ready) begin 
            out_data <= {in_data, out_data[OUTPUT_WIDTH-1 : DATA_WIDTH]};
        end
    end


endmodule