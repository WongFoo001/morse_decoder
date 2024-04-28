`timescale 1ns / 1ps

/*
symbol_rx.sv:

  This module translates button presses/releases into dots and dashes. It buffers dots and dashes
  into characters to be decoded. Note that all letters and numbers (0-9) can be represented
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

  typedef enum {
    IDLE,
    BTN_PRESSED,
    BTN_RELEASED,
    SENT_CHAR
  } symbol_rx_fsm_t;
  symbol_rx_fsm_t fsm_r, fsm_next_s;

  // symbol buffer
  logic [MORSE_CHAR_WIDTH_MAX_C-1:0] sym_buffer_r;
  logic [MORSE_SIZE_WIDTH_MAX_C-1:0] size_r;

  // rx timer control signals
  logic dash_exp_s, dash_set_r;
  logic illegal_exp_s, illegal_set_r;
  logic char_exp_s, char_set_r;
  logic word_exp_s, word_setp_r;

  // rx timer instantiations
  timer #(.TICK_COUNT(DASH_TICK_COUNT_C)) dash_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(dash_set_r),
    .expired_o(dash_exp_s)
  );

  timer #(.TICK_COUNT(ILLEGAL_SYMBOL_TICK_COUNT_C)) illegal_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(illegal_set_r),
    .expired_o(illegal_exp_s)
  );

  timer #(.TICK_COUNT(CHAR_TICK_COUNT_C)) char_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(char_set_r),
    .expired_o(char_exp_s)
  );

  timer #(.TICK_COUNT(WORD_TICK_COUNT_C)) word_timer (
    .clk(clk),
    .resetn(resetn),
    .set_i(word_setp_r),
    .expired_o(word_exp_s)
  );

  /*
    symbol rx FSM logic
  */
  always_ff @ (posedge clk) begin
    if (!resetn) begin
      fsm_r         <= IDLE;
      sym_buffer_r  <= 0;
      size_r        <= 0;
      dash_set_r    <= 1;
      illegal_set_r <= 1;
      char_set_r    <= 1;
      word_set_r    <= 1;

      // reset outputs
      tvalid_o <= 0;
      tdata_o <= 0;
      tsize_o <= 0;
    end

    else begin
      // default assignments
      fsm_r         <= fsm_r;
      sym_buffer_r  <= sym_buffer_r;
      size_r        <= size_r;
      dash_set_r    <= dash_set_r;
      illegal_set_r <= illegal_set_r;
      char_set_r    <= char_set_r;
      word_setp_r   <= word_setp_r;

      // default outputs
      tvalid_o <= tvalid_o;
      tdata_o <= tdata_o;
      tsize_o <= tsize_o;

      // logic to advance statemachine
      case (fsm_r)
        IDLE: begin
          // rx is idle, buffer is empty
          sym_buffer_r  <= 0;
          size_r        <= 0;

          // keep timers idle
          dash_set_r    <= 1;
          illegal_set_r <= 1;
          char_set_r    <= 1;
          word_set_r    <= 1;

          // button pressed, symbol incoming
          if (btn_i == 1) begin
            fsm_r <= BTN_PRESSED;
          end
        end

        BTN_PRESSED: begin
          // dash and illegal symbol timers counting
          dash_set_r    <= 0;
          illegal_set_r <= 0;

          // keep char and word timers idle
          char_set_r    <= 1;
          word_set_r    <= 1;

          // button held too long, symbol timed out
          if (illegal_exp_r == 1) begin
            fsm_r <= IDLE;
          end

          // button released in time, valid symbol
          else if (btn_i == 0) begin
            // less than 5 symbols seen
            if (size_r < MORSE_CHAR_WIDTH_MAX_C) begin
              fsm_r <= BTN_RELEASED;

              // add dot/dash to buffer
              sym_buffer_r[size_r] <= dash_exp_s;
              // icrement size counter
              size_r <= size_r + 1;
            end
            
            // if 5 symbols already seen, this character is illegal
            else begin
              fsm_r <= IDLE;

              // reset buffer and size counter
              sym_buffer_r <= 0;
              size_r <= 0;
            end
          end
        end
        
        BTN_RELEASED: begin
          // char and word timers counting
          char_set_r    <= 0;
          word_set_r    <= 0;

          // keep dash and illegal timers idle
          dash_set_r    <= 1;
          illegal_set_r <= 1;

          // end of char detected
          if (char_exp_s == 1) begin
            fsm_r <= SENT_CHAR;

            // send char out
            tvalid_o <= 1;
            tdata_o <= sym_buffer_r;
            tsize_o <= size_r;

            // reset buffer and size counter
            sym_buffer_r <= 0;
            size_r <= 0;
          end

          // another button press
          else if (btn_i == 1) begin
            fsm_r <= BTN_PRESSED;
          end
        end

        SENT_CHAR: begin
          // keep dash, illegal, and char timers idle
          dash_set_r    <= 1;
          illegal_set_r <= 1;
          char_set_r    <= 1;

          // end of char detected
          if (word_exp_s_exp_s == 1) begin
            fsm_r <= IDLE;

            // send special space character out
            tvalid_o <= 1;
            tdata_o <= MORSE_SPACE_C;
            tsize_o <= MORSE_CHAR_WIDTH_MAX_C;
          end

          // another button press
          else if (btn_i == 1) begin
            fsm_r <= BTN_PRESSED;
          end
        end

        // should never get here, undefined
        default: $display("Illegal symbol_rx state @ %d", $time);
      endcase
    end
  end
endmodule