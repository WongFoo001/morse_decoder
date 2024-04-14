`timescale 1ns / 1ps

/*
cdc.sv:

  This module is a parameterizable-width three-stage synchronizer 
  used to synchronize an asynchronous input to the provided clock domain.
*/

module cdc #(parameter DATA_WIDTH = 1) (
  input logic clk,
  input logic resetn,
  input logic [DATA_WIDTH-1:0] async_sig_i,

  output logic [DATA_WIDTH-1:0] sync_sig_o
);

  logic [DATA_WIDTH-1:0] stage1_r, stage2_r, stage3_r;

  always_ff @ (posedge clk) begin
    if (!resetn) begin
      stage1_r <= '0;
      stage2_r <= '0;
      stage3_r <= '0;
    end

    else begin
      stage1_r <= async_sig_i;
      stage2_r <= stage1_r;
      stage3_r <= stage2_r;
    end
  end

  assign sync_sig_o = stage3_r;
endmodule