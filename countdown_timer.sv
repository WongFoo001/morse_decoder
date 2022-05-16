`timescale 1ns / 1ps
/*
	Conversion: 
	Cycle Time given 100MHz clock: 10ns
	tick_count = cd_time / 10ns

	Default 0.5s countdown
*/
module countdown_timer #(parameter tick_count = d'50_000_000)(
	input logic clk_100Mhz,
	input logic reset,

	output logic time_out
);
	// Data signal declarations
	localparam WIDTH = $clog2(tick_count); // Synthesizable given tick_count is constant, defined pre_compile
	logic [WIDTH-1 : 0] time_count_d, time_count_q;
	always_comb begin
		// Default do not count statement
		time_count_d = time_count_q;

		// Only decrement if time_count is non-zero;
		if (time_count_q != 0) begin
			time_count_d = time_count_q - 1'b1;
		end
	end

	always_ff @ (posedge clk_100Mhz) begin
		if (reset) begin
			// Reset counter
			time_count_q <= tick_count;
		end
		else begin
			time_count_q <= time_count_d;
		end
	end 
endmodule 