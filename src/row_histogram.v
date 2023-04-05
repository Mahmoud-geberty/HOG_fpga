module row_histogram #(
    parameter DATA_WIDTH      = 8, 
    parameter BIN_WIDTH       = 11, 
    parameter HISTOGRAM_WIDTH = BIN_WIDTH * 9 
) (
    input                            clk, rst, 
    input                            in_valid, out_ready, 
    input [DATA_WIDTH-1:0]           magnitude, 
    input [3:0]                      bin_index, 
    output                           out_valid, in_ready, 
    output [HISTOGRAM_WIDTH-1:0]     row_histogram 
); 

    // TODO: Add an intermediate state to output combinationally, next cycle output the 
    //       registered one. 
    parameter S_IDLE = 0; 
    parameter S_ACCUM = 1; 
    parameter S_BYPASS = 2;
    parameter S_VALID = 3; 
    reg [1:0] current_state, next_state; 

    reg [HISTOGRAM_WIDTH-1:0] bin_accum; 
    reg [HISTOGRAM_WIDTH-1:0] bin_accum_reg; 
    reg [3:0] bin_cnt; 

    // perform the accumulation combinationally
    always @(*) begin 
        bin_accum = bin_accum_reg; // default value;
        case (bin_index)
            4'd0: begin 
                bin_accum[0*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[0*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd1: begin 
                bin_accum[1*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[1*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd2: begin 
                bin_accum[2*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[2*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd3: begin 
                bin_accum[3*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[3*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd4: begin 
                bin_accum[4*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[4*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd5: begin 
                bin_accum[5*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[5*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd6: begin 
                bin_accum[6*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[6*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd7: begin 
                bin_accum[7*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[7*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
            4'd8: begin 
                bin_accum[8*BIN_WIDTH +: BIN_WIDTH] = 
                    bin_accum_reg[8*BIN_WIDTH +: BIN_WIDTH] + magnitude;
            end
        endcase
    end

    // register the accumalator values, except the last one which is output directly.
    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            bin_accum_reg <= 0; 
        end
        else if (next_state == S_IDLE) begin 
            bin_accum_reg <= 0; 
        end
        else if (current_state != S_VALID) begin 
            bin_accum_reg <= bin_accum; 
        end
    end

    assign row_histogram = (current_state != S_VALID)? bin_accum: bin_accum_reg; 

    always @(*) begin 
        next_state = current_state;
        case (current_state)
            S_IDLE: begin 
                if (in_valid && in_ready) begin 
                    next_state = S_ACCUM; 
                end
            end
            S_ACCUM: begin 
                if (bin_cnt == 4'd6 && (in_valid && in_ready)) begin 
                    next_state = S_BYPASS; 
                end
            end
            S_BYPASS: begin 
                if (out_valid && out_ready) begin 
                    next_state = S_IDLE; 
                end
                else begin 
                    next_state = S_VALID;
                end
            end
            S_VALID: begin 
                if (out_valid && out_ready) begin 
                    next_state = S_IDLE; 
                end
            end
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

    assign out_valid = (current_state == S_VALID || current_state == S_BYPASS) && in_valid; 
    // assign in_ready = (current_state == S_VALID)? out_ready : 1'b1;
    assign in_ready = (current_state != S_VALID)? 1'b1 : out_ready;

    always @(posedge clk, posedge rst) begin 
        if (rst) begin 
            bin_cnt <= 4'd0; 
        end
        else if (out_valid && out_ready) begin 
            bin_cnt <= 4'd0; 
        end
        else if (in_valid && in_ready && current_state < S_BYPASS) begin 
            bin_cnt <= bin_cnt + 4'd1; 
        end
    end

endmodule