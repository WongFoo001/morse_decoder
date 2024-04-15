`timescale 1ns / 1ps

/*
symbol_rx.sv:

  This module translates button presses into dots and dashes. It buffers dots and dashes
  into symbol-bytes to be decoded. Note that all letters and numbers (0-9) can be represented
  with only 5 bits. Hence symbol buffer is only 5 symbols long. A string of dots/dashes longer
  that 5 bits will be thrown away.
*/

module symbol_rx (
  input logic clk,
  input logic resetn,

  // debounced button input
  input logic btn_i,

  // character output to decoder
  output logic tvalid_o,
  output logic [MORSE_CHAR_WIDTH_MAX_C-1:0] tdata_o,
  output logic [MORSE_SIZE_WIDTH_MAX_C-1:0] tsize_o
);
  import morse_decoder_pkg::*;

  // symbol buffer
  logic [MORSE_CHAR_WIDTH_MAX_C-1:0] sym_buffer_r;
  logic [MORSE_SIZE_WIDTH_MAX_C-1:0] size_r;

  // output control signals
  logic prev_send_char_r, send_char_r;
  logic prev_send_space_r, send_space_r;

  // rx timer control signals
  logic dash_exp_r, dash_set_r;
  logic illegal_exp_r, illegal_set_r;
  logic char_exp_r, char_set_r;
  logic word_exp_r, word_setp_r;

  // rx timer instantiations
  timer #(.TICK_COUNT(DASH_TICK_COUNT_C)) dash_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(dash_set_r),
    .expired_o(dash_exp_r)
  );

  timer #(.TICK_COUNT(ILLEGAL_SYMBOL_TICK_COUNT_C)) illegal_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(illegal_set_r),
    .expired_o(illegal_exp_r)
  );

  timer #(.TICK_COUNT(CHAR_TICK_COUNT_C)) char_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(char_set_r),
    .expired_o(char_exp_r)
  );

  timer #(.TICK_COUNT(WORD_TICK_COUNT_C)) word_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(word_setp_r),
    .expired_o(word_exp_r)
  );
endmodule