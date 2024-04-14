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
    logic tb_btn_t_res   ;
    logic tb_dash_t_res  ;
    logic tb_inter_t_res ; 
    logic tb_word_t_res  ;  

    // Data Signals
    logic [5:0] tb_char_data  ;
    logic [2:0] tb_char_index ; 
    logic       tb_char_valid ;


	// Instance of DUT - morse_rx
	morse_rx rx(.clk_100MHz(tb_clk_100MHz), .reset(tb_reset), .user_btn(tb_user_btn), .btn_to(tb_btn_to), 
				.dash_to(tb_dash_to), .inter_to(tb_inter_to), .word_to(tb_word_to), .btn_t_res(tb_btn_t_res), .dash_t_res(tb_dash_t_res), 
				.inter_t_res(tb_inter_t_res), .word_t_res(tb_word_t_res), .char_data(tb_char_data), .char_index(tb_char_index), .char_valid(tb_char_valid));

	// Clock Driver
    initial begin   
    	#1 tb_clk_100MHz = 1'b1;
       	forever begin
            #1 tb_clk_100MHz = ~tb_clk_100MHz; // Period of clk 10 time units
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
		
		// -- Send Letter A {dot, dash} --
            // Send first button press
            tb_user_btn = 1'b1;
            #5;
    
            // Send button release -> dot/dash judge, store a dot = no dash_to
            tb_user_btn   <= 1'b0;
            #5;
    
            // Send second button press 
            tb_user_btn   <= 1'b1;
            #5;
            
            // Dash timeout 
            tb_dash_to  <= 1'b1;
            #2
            
            // Send button release -> dot/dash judge, store a dash = dash_to
            tb_user_btn <= 1'b0;
            #5;
    
            // Store an 'a' -> inter_to 
            tb_dash_to     <= 1'b0;
            tb_inter_to    <= 1'b1; 
            #2; 
            
            // Reset tb_inter_to
            tb_inter_to    <= 1'b0; 
            #5;
            
         // -- Send Letter C {dash, dot, dash, dot} --
            // Send first button press
            tb_user_btn = 1'b1;
            #2;
            
            // Dash timeout 
            tb_dash_to  <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dash
            tb_user_btn   <= 1'b0;
            #5;
            
            // Dash timeout reset
            tb_dash_to  <= 1'b0;
            #5;
            
            // Send second button press 
            tb_user_btn   <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dot
            tb_user_btn <= 1'b0;
            #5;
            
            // Send third button press
            tb_user_btn = 1'b1;
            #2;
            
            // Dash timeout 
            tb_dash_to  <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dash
            tb_user_btn   <= 1'b0;
            #5;
            
            // Dash timeout reset
            tb_dash_to  <= 1'b0;
            #5;
            
            // Send second button press 
            tb_user_btn   <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dot
            tb_user_btn <= 1'b0;
            #5;
    
            // Store an 'c' -> inter_to 
            tb_dash_to     <= 1'b0;
            tb_inter_to    <= 1'b1; 
            #2; 
            
            // Reset tb_inter_to
            tb_inter_to    <= 1'b0; 
            #5;
            
        // -- Send Letter K {dash, dot, dash} --
            // Send first button press
            tb_user_btn = 1'b1;
            #2;
            
            // Dash timeout 
            tb_dash_to  <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dash
            tb_user_btn   <= 1'b0;
            #4;
            
            // Dash timeout reset
            tb_dash_to  <= 1'b0;
            #5;
            
            // Send second button press 
            tb_user_btn   <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dot
            tb_user_btn <= 1'b0;
            #5;
            
            // Send third button press
            tb_user_btn = 1'b1;
            #2;
            
            // Dash timeout 
            tb_dash_to  <= 1'b1;
            #5;
            
            // Send button release -> dot/dash judge, store a dash
            tb_user_btn   <= 1'b0;
            #4;
            
            // Dash timeout reset
            tb_dash_to  <= 1'b0;
            #5;
    
            // Store an 'k' -> inter_to 
            tb_inter_to    <= 1'b1; 
            #2; 
            
            // Reset tb_inter_to
            tb_inter_to    <= 1'b0; 
            #5;
            
		// -- Send Space completing "ack" word --
		tb_word_to <= 1'b1;
		#2;
		
		tb_word_to <= 1'b0;
		#20;
		$finish(); // End simulation
	end 
endmodule