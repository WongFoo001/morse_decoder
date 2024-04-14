`timescale 1ns / 1ps

/*
clk_gen.sv:

  This module is a parameterizable clock generator with a
  default 100Mhz output clock.
*/

module clk_gen #(parameter HALF_CLK_DELAY = 5) (
  output logic clk_o
);
  initial begin
    clk_o <= 0;

    forever #5 clk_o <= ~clk_o;
  end
endmodule