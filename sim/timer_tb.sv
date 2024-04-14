module timer_tb();
  import morse_decoder_pkg::*;
  `include "stim_utilities.svh"
  
  logic clk, resetn;
  logic dash_expired, illegal_expired, inter_idle_expired, word_expired;

  timer #(.TICK_COUNT(DASH_TICK_COUNT_C)) dash_dut (
    .clk(clk),
    .resetn(resetn),
    .expired_o(dash_expired)
  );

  timer #(.TICK_COUNT(ILLEGAL_SYMBOL_TICK_COUNT_C)) illegal_dut (
    .clk(clk),
    .resetn(resetn),
    .expired_o(illegal_expired)
  );

  timer #(.TICK_COUNT(INTER_IDLE_TICK_COUNT_C)) inter_dut (
    .clk(clk),
    .resetn(resetn),
    .expired_o(inter_idle_expired)
  );

  timer #(.TICK_COUNT(WORD_IDLE_TICK_COUNT_C)) word_dut (
    .clk(clk),
    .resetn(resetn),
    .expired_o(word_expired)
  );

  // monitor timers
  initial begin
    // reset timers before they expire
    do_reset();
    wait_num_clks(DASH_TICK_COUNT_C / 2);

    // see all timers expire normally
    do_reset();
    wait_num_clks(1.5 * WORD_IDLE_TICK_COUNT_C);

    $finish();
  end
endmodule