// directly copied from...
// https://www.intel.com/content/www/us/en/docs/programmable/683323/18-1/true-dual-port-synchronous-ram.html
module true_dual_port #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 6
)(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk, rd_a, rd_b,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);


	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	always @ (posedge clk)
	begin // Port a
		if (we_a)
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else if (rd_a)
			q_a <= ram[addr_a];
	end

	always @ (posedge clk)
	begin // Port b
		if (we_b)
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else if (rd_b)
			q_b <= ram[addr_b];
	end
endmodule