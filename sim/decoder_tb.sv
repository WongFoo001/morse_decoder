`timescale 1ns / 1ps

module decoder_tb();
	logic tb_clk_100Mhz ; // Clock
    logic tb_reset     ; // Reset                 

    // Data Signals
    logic        tb_data_valid ;
    logic [2:0]  tb_char_index ;
    logic [5:0]  tb_char_data  ; 

    // Output Signals
    logic [55:0] tb_seg ;

    // Local Seg signals
    logic [6:0] seg0 ;
    logic [6:0] seg1 ;
    logic [6:0] seg2 ;
    logic [6:0] seg3 ;
    logic [6:0] seg4 ;
    logic [6:0] seg5 ;
    logic [6:0] seg6 ;
    logic [6:0] seg7 ;

	// Instance of DUT - morse_rx
	decoder uut (.clk_100Mhz(tb_clk_100Mhz), .reset(tb_reset), .data_valid(tb_data_valid), .char_index(tb_char_index), .char_data(tb_char_data),
                    .seg(tb_seg));

	// Clock Driver
    initial begin   
    	#1 tb_clk_100Mhz = 1'b1;
       	forever begin
            #1 tb_clk_100Mhz = ~tb_clk_100Mhz; // Period of clk 10 time units
        end
	end
    
    // Local Output assignment - For "Debuggibility"
    assign seg0 = tb_seg[6:0] ;
    assign seg1 = tb_seg[13:7] ;
    assign seg2 = tb_seg[20:14] ;
    assign seg3 = tb_seg[27:21] ;
    assign seg4 = tb_seg[34:28] ;
    assign seg5 = tb_seg[41:35] ;
    assign seg6 = tb_seg[48:42] ;
    assign seg7 = tb_seg[55:49] ;
    
	// Input Driver
	initial begin
		// Initial Input settings
		tb_reset      <= 1'b0;
		tb_data_valid <= 1'b1;
		tb_char_index <= 1'b0;
		tb_char_data  <= 6'b000000;
		#5;
	end 

    always @ (posedge tb_clk_100Mhz) begin
        case (tb_char_data)
            6'b000001: tb_char_index <= tb_char_index + 1;

            6'b000011: tb_char_index <= tb_char_index + 1;

            6'b000111: tb_char_index <= tb_char_index + 1;

            6'b001111: tb_char_index <= tb_char_index + 1;

            6'b011111: $finish();
        endcase
        tb_char_data <= tb_char_data + 1;
    end
    
endmodule