`timescale 1ns / 1ps

module debouncer_tb();
	logic tb_clk_100Mhz;
	logic tb_reset;
	logic tb_btn_in;

	logic tb_btn_press;

	// Unit under test
	debouncer #(.TICK_COUNT(8)) testDebouncer (.clk_100Mhz(tb_clk_100Mhz), .reset(tb_reset), .btn_in(tb_btn_in), .btn_press(tb_btn_press));


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
		tb_btn_in <= 1'b0;
		#5;

		// Reset System
		tb_reset  <= 1'b1;
		#10;

		tb_reset  <= 1'b0;
		#10;

		// Start Debouncer - Hold button long enough
		tb_btn_in <= 1'b1;
		#70;

		tb_btn_in <= 1'b0;
		#10;

		// Start Debouncer - Don't hold button long enough
		tb_btn_in <= 1'b1;
		#20;

		tb_btn_in <= 1'b0;
		#10;

		$finish(); // End Sim
	end
endmodule
