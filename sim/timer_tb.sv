module timer_tb();
  import morse_decoder_pkg::*;
  `include "stim_utilities.svh"
  
  logic resetn;
  logic dash_set, dash_expired;
  logic illegal_set, illegal_expired;
  logic char_set, char_expired;
  logic word_set, word_expired;

  timer #(.TICK_COUNT(DASH_TICK_COUNT_C)) dash_dut (
    .clk(clk),
    .resetn(resetn),
    .set_i(dash_set),
    .expired_o(dash_expired)
  );

  timer #(.TICK_COUNT(ILLEGAL_SYMBOL_TICK_COUNT_C)) illegal_dut (
    .clk(clk),
    .resetn(resetn),
    .set_i(illegal_set),
    .expired_o(illegal_expired)
  );

  timer #(.TICK_COUNT(CHAR_TICK_COUNT_C)) char_dut (
    .clk(clk),
    .resetn(resetn),
    .set_i(char_set),
    .expired_o(char_expired)
  );

  timer #(.TICK_COUNT(WORD_TICK_COUNT_C)) word_dut (
    .clk(clk),
    .resetn(resetn),
    .set_i(word_set),
    .expired_o(word_expired)
  );

  task set_timers();
    dash_set = 1;
    illegal_set = 1;
    char_set = 1;
    word_set = 1;
  endtask

  task enable_timers();
    dash_set = 0;
    illegal_set = 0;
    char_set = 0;
    word_set = 0;
  endtask

  /*
  * testbench stimulus
  */
  initial begin
    // hold timers idle
    set_timers();

    // reset
    do_reset();

    // let timers count
    enable_timers();
    wait_num_clks(DASH_TICK_COUNT_C / 2);

    // re-set them to check that exit path
    set_timers();
    wait_num_clks(100);

    // finally allow timers to expire
    enable_timers();
    wait_num_clks(1.5 * WORD_TICK_COUNT_C);

    $finish();
  end
endmodule