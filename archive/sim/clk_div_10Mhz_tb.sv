`timescale 1ns / 1ps

module clk_div_10Mhz_tb();
	// Signal declarations
	logic tb_clk_100Mhz;
	logic tb_reset;

	logic tb_clk_10Mhz;

	// Unit instance
	clk_div_10Mhz clk_10Mhz(.clk_100Mhz(tb_clk_100Mhz), .reset(tb_reset), .clk_10Mhz(tb_clk_10Mhz));

	// Generate clock signal
	initial begin
		#1 tb_clk_100Mhz = 1;

		forever begin
			#1 tb_clk_100Mhz = ~tb_clk_100Mhz;
		end
	end

	// Generate input stimulus
	initial begin
		// Initial reset
		tb_reset = 1'b1;
		#5;

		tb_reset = 1'b0;
		#80;
		$finish();
	end
endmodule