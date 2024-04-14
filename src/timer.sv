`timescale 1ns / 1ps

/*
timer.sv:

  This module is a parameterizable countdown timer.
*/

module timer #(parameter TICK_COUNT) (
  input logic clk,
  input logic resetn,

  output logic expired_o
);
  logic [$clog2(TICK_COUNT+1)-1:0] count_r;

  always_ff @ (posedge clk) begin
    if (!resetn) begin
      count_r <= TICK_COUNT;
    end

    else begin
      if (count_r > 0) begin
        count_r <= count_r - 1;
      end

      else begin
        count_r <= count_r;
      end
    end
  end

  assign expired_o = (count_r === 0); 
endmodule