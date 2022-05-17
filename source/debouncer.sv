`timescale 1ns / 1ps
/*
	Conversion: 
	Cycle Time given 100MHz clock: 10ns
	tick_count = cd_time / 10ns

	Default 50ms countdown
*/
module debouncer #(parameter TICK_COUNT = 5000000)(
	input logic clk_100Mhz,
	input logic reset,
	input logic btn_in, 

	output logic btn_press
);
	// Data signal declarations
	localparam WIDTH = $clog2(TICK_COUNT+1); // Synthesizable given tick_count is constant, defined pre_compile
	logic [WIDTH-1 : 0] time_count_d, time_count_q;

	logic btn_press_d, btn_press_q;

	always_comb begin
		// Default do not count statement
		time_count_d = time_count_q;
		btn_press_d  = 0; 

		// If full count, check if btn still being held -> actual button press
		if (time_count_q == TICK_COUNT) begin
			time_count_d = time_count_q; // Hold counter
			if (btn_in) begin
				btn_press_d = 1'b1;
			end
			else begin // If button not being held, reset counter
				time_count_d = 0;
			end
		end

		// Increment time counter	
		else begin
			time_count_d = time_count_q + 1'b1;
		end
	end

	always_ff @ (posedge clk_100Mhz) begin
		if (reset) begin
			// Reset counter and output
			time_count_q <= 0;
			btn_press_q  <= 0;
		end

		else begin
			time_count_q <= time_count_d;
			btn_press_q  <= btn_press_d;
		end
	end 
	
	// Assign outputs
	always_comb begin
	   btn_press = btn_press_q;
	end
endmodule 