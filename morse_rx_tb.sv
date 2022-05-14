`timescale 1ns / 1ps

module morse_rx_tb();
	logic tb_clk_100MHz ; // Clock
    logic tb_reset      ; // Reset
    logic tb_user_btn   ; // Button Signal from Debouncer

    // Timer Done Signals
    logic tb_btn_to     ;
    logic tb_dash_to    ; 
    logic tb_inter_to   ;
    logic tb_word_to    ;

    // Timer Reset Signals
    logic tb_btn_to_res   ;
    logic tb_dash_to_res  ;
    logic tb_inter_to_res ; 
    logic tb_word_to_res  ;  

    // Data Signals
    logic [5:0] tb_char_data  ;
    logic       tb_char_valid ;


	// Instance of DUT - morse_rx
	morse_rx rx(.clk_100MHz(tb_clk_100MHz), .reset(tb_reset), .user_btn(tb_user_btn), .btn_to(tb_btn_to), 
				.dash_to(tb_dash_to), .inter_to(tb_inter_to), .word_to(tb_word_to), .btn_to_res(tb_btn_to_res), .dash_to_res(tb_dash_to_res), 
				.inter_to_res(tb_inter_to_res), .word_to_res(tb_word_to_res), .char_data(tb_char_data), .char_valid(tb_char_valid));

	// Clock Driver
    initial begin   
    	#2 tb_clk_100MHz = 1'b1;
       	forever begin
            #2 tb_clk_100MHz = ~tb_clk_100MHz; // Period of clk 10 time units
        end
	end

	// Input Driver
	initial begin
		// Initial Input settings
		tb_reset    <= 1'b0;
		tb_user_btn <= 1'b0;
		tb_btn_to   <= 1'b0;
		tb_dash_to  <= 1'b0;
		tb_inter_to <= 1'b0;
		tb_word_to  <= 1'b0;
		#5;

		// Reset system
		tb_reset    <= 1'b1;
		#5;

		// Idle system, in IDLE state
		tb_reset    <= 1'b0;
		#5;
		
		// Send first button press
		tb_user_btn = 1'b1;
		#5;

		// Let button timeout -> return to idle
		tb_btn_to   <= 1'b1;
		#10;

		// Reset timeout and user btn
		tb_btn_to   = 1'b0;
		tb_user_btn = 1'b0;
		#5;

		// Send successful button press this time
		tb_user_btn   <= 1'b1;
		#5;

		// Send button release -> dot/dash judge, store a dot = no dash_to
		tb_user_btn   <= 1'b0;
		#5;

		// Send third button press 
		tb_user_btn   <= 1'b1;
		#5; 

		// Send button release -> dot/dash judge, store a dash = no dash_to
		tb_dash_to  <= 1'b1;
		tb_user_btn   <= 1'b0;
		#5;

		// Store an 'a' -> inter_to 
		tb_dash_to     <= 1'b0;
		tb_inter_to    <= 1'b1; 
		#10; 
		
		$finish(); // End simulation
	end 
endmodule