package morse_decoder_pkg;
	/*
	Timing Scheme:
		- Dot       : Button pushed for >0s - 0.3s
		- Dash      : Button pushed for 0.3s - 1s
		- Character : Idle for 1.75s - 2.5s
		- Word      : Idle for >2.5s
	*/

	parameter DASH_TICK_COUNT_C = 30_000_000;
	parameter ILLEGAL_SYMBOL_TICK_COUNT_C = 100_000_000;
	parameter CHAR_TICK_COUNT_C = 175_000_000;
	parameter WORD_TICK_COUNT_C = 250_000_000;

	/*
	Button debouncer transition threshold:
		normal : 20ms
		debug  : 1000ns
	*/
	parameter DEBOUNCE_THRESHOLD_C = 2_000_000;
	// parameter DEBOUNCE_THRESHOLD_C = 100;

	/*
	Decoding Scheme:
		All english letters and numbers (0-9) can be represented with only
		5 morse code symbols. See docs/morse-code-tree.png for the
		decoding tree structure. Encoding is read from left to right
		where the MSB is the first symbol transmitted and the LSB is the
		last symbol transmitted.

		dot - 1'b0
		dash - 1'b1
	*/
	parameter MORSE_A_C = 5'b01xxx;
	parameter MORSE_B_C = 5'b1000x;
	parameter MORSE_C_C = 5'b1010x;
	parameter MORSE_D_C = 5'b100xx;
	parameter MORSE_E_C = 5'b0xxxx;
	parameter MORSE_F_C = 5'b0010x;
	parameter MORSE_G_C = 5'b110xx;
	parameter MORSE_H_C = 5'b0000x;
	parameter MORSE_I_C = 5'b00xxx;
	parameter MORSE_J_C = 5'b0111x;
	parameter MORSE_K_C = 5'b101xx;
	parameter MORSE_L_C = 5'b0100x;
	parameter MORSE_M_C = 5'b11xxx;
	parameter MORSE_N_C = 5'b10xxx;
	parameter MORSE_O_C = 5'b111xx;
	parameter MORSE_P_C = 5'b0110x;
	parameter MORSE_Q_C = 5'b1101x;
	parameter MORSE_R_C = 5'b010xx;
	parameter MORSE_S_C = 5'b000xx;
	parameter MORSE_T_C = 5'b1xxxx;
	parameter MORSE_U_C = 5'b001xx;
	parameter MORSE_V_C = 5'b0001x;
	parameter MORSE_W_C = 5'b011xx;
	parameter MORSE_X_C = 5'b1001x;
	parameter MORSE_Y_C = 5'b1011x;
	parameter MORSE_Z_C = 5'b1100x;
	parameter MORSE_0_C = 5'b11111;
	parameter MORSE_1_C = 5'b01111;
	parameter MORSE_2_C = 5'b00111;
	parameter MORSE_3_C = 5'b00011;
	parameter MORSE_4_C = 5'b00001;
	parameter MORSE_5_C = 5'b00000;
	parameter MORSE_6_C = 5'b10000;
	parameter MORSE_7_C = 5'b11000;
	parameter MORSE_8_C = 5'b11100;
	parameter MORSE_9_C = 5'b11110;
	// special parameter that instructs decoder to insert
	// a space.
	parameter MORSE_SPACE_C = 5'b11111;

	// signal connection width parameters
	parameter MORSE_CHAR_WIDTH_MAX_C = 5;
	parameter MORSE_SIZE_WIDTH_MAX_C = 3;
endpackage