`timescale 1ns / 1ps

module an_ring_counter_tb();
	// Signal declarations
	logic tb_clk_10Mhz;
	logic tb_reset;

	logic [7:0] tb_an_sel;

	// Unit instance
	an_ring_counter an_ring(.clk_10Mhz(tb_clk_10Mhz), .reset(tb_reset), .an_sel(tb_an_sel));

	// Generate clock signal
	initial begin
		#2 tb_clk_10Mhz = 1;

		forever begin
			#2 tb_clk_10Mhz = ~tb_clk_10Mhz;
		end
	end

	// Generate input stimulus
	initial begin
		// Initial reset
		tb_reset = 1'b1;
		#5;

		tb_reset = 1'b0;
		#40;
		$finish();
	end
endmodule