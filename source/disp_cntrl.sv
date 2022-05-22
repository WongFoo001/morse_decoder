`timescale 1ns / 1ps

module disp_cntrl(
	input        clk_10Mhz ,
	input        reset     ,
	input [63:0] seg_data  ,
	input [7:0]  an_sel    ,

	output [7:0] seg ,
	output [7:0] an 
);
	
	// Internal data declarations
	logic [7:0] seg_d, seg_q;

	// Data Logic
	always_comb begin
		case(an_sel) begin
			8'b11111110: seg_d = seg_data[7:0]; 

			8'b11111101: seg_d = seg_data[15:8]; 

			8'b11111011: seg_d = seg_data[23:16]; 

			8'b11110111: seg_d = seg_data[31:24]; 

			8'b11101111: seg_d = seg_data[39:32]; 

			8'b11011111: seg_d = seg_data[47:40]; 

			8'b10111111: seg_d = seg_data[55:48]; 

			8'b01111111: seg_d = seg_data[63:56];

			default: seg_d = 8'b11111111; // shouldn't execute
		end
	end

	// Data FFs
	always_ff @ (posedge clk_100Mhz) begin
		if (reset) seg_q <= 8'b11111111;

		else seg_q <= seg_d;
	end

	// Output assignment
	always_comb begin
		seg = seg_q  ;
		an  = an_sel ;
	end