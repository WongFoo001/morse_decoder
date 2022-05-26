`timescale 1ns / 1ps

module disp_cntrl_tb();
	logic tb_clk_10MHz ; // Clock
    logic tb_reset     ; // Reset

    // Data Signals
    logic [63:0] tb_seg_data ;
    logic [7:0]  tb_an_sel   ; 

    // Output Signals
    logic [7:0] tb_seg ;
    logic [7:0] tb_an  ; 

	// Instance of DUT - morse_rx
	disp_cntrl uut (.clk_10Mhz(tb_clk_10MHz), .reset(tb_reset), .seg_data(tb_seg_data), .an_sel(tb_an_sel),
                    .seg(tb_seg), .an(tb_an));

    // Instance of anode ring control
    an_ring_counter an_cnt(.clk_10Mhz(tb_clk_10MHz), .reset(tb_reset),
                           .an_sel(tb_an_sel));
	// Clock Driver
    initial begin   
    	#1 tb_clk_10MHz = 1'b1;
       	forever begin
            #1 tb_clk_10MHz = ~tb_clk_10MHz; // Period of clk 10 time units
        end
	end

	// Input Driver
	initial begin
		// Initial Input settings
		tb_reset    <= 1'b0;
		tb_seg_data <= 64'b10000000_01000000_00100000_00010000_00001000_00000100_00000010_00000001;
		#5;

		// Reset system
		tb_reset    <= 1'b1;
		#5;

		// Let system run
		tb_reset    <= 1'b0;
		#150;
        $finish();
	end 
endmodule