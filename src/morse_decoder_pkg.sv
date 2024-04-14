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

	// Button debouncer transition threshold - 20ms
	// parameter DEBOUNCE_THRESHOLD_C = 2_000_000;

	// temporary for SIM debounce parameter
	parameter DEBOUNCE_THRESHOLD_C = 100;
endpackage