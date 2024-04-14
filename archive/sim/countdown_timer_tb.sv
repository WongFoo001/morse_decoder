`timescale 1ns / 1ps

module countdown_timer_tb();
	logic tb_clk_100Mhz;
	logic tb_reset;

	logic tb_time_out;

	// Unit under test
	countdown_timer #(.TICK_COUNT(8)) test_time (.clk_100Mhz(tb_clk_100Mhz), .reset(tb_reset), .time_out(tb_time_out));


	// Clock instantiation
	initial begin
		#4 tb_clk_100Mhz = 1;
		forever begin
			#3 tb_clk_100Mhz = ~tb_clk_100Mhz;
		end
	end

	// Input stimulus
	initial begin
		// Initial Settings
		tb_reset  <= 1'b0;
		#5;

		// Reset System
		tb_reset  <= 1'b1;
		#10;

		tb_reset  <= 1'b0;
		#50;

		// Reset System
		tb_reset  <= 1'b1;
		#10;

		tb_reset  <= 1'b0;
		#20;

		// Reset System
		tb_reset  <= 1'b1;
		#10;

		tb_reset  <= 1'b0;
		#50;

		$finish(); // End Sim
	end
endmodule
