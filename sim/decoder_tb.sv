`timescale 1ns / 1ps

module decoder_tb();
	logic tb_clk_100MHz ; // Clock
    logic tb_reset     ; // Reset                 

    // Data Signals
    logic        tb_data_valid ;
    logic        tb_char_index ;
    logic [5:0]  tb_char_data  ; 

    // Output Signals
    logic [63:0] tb_seg ;

	// Instance of DUT - morse_rx
	decoder uut (.clk_100Mhz(tb_clk_100MHz), .reset(tb_reset), .data_valid(tb_data_valid), .char_index(tb_char_index), .char_data(tb_char_data),
                    .seg(tb_seg));

	// Clock Driver
    initial begin   
    	#1 tb_clk_100Mhz = 1'b1;
       	forever begin
            #1 tb_clk_100Mhz = ~tb_clk_100Mhz; // Period of clk 10 time units
        end
	end

	// Input Driver
	initial begin
		// Initial Input settings
		tb_reset      <= 1'b0;
		tb_data_valid <= 1'b1;
		tb_char_index <= 1'b0;
		tb_char_data  <= 6'b000000;
		#5;
	end 

	always begin
		@posedge tb_clk_100Mhz 
		tb_char_data <= tb_char_data + 1;
	end
endmodule