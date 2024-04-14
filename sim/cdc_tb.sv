module cdc_tb();
  `include "stim_utilities.svh"

  parameter DATA_WIDTH = 4;
  parameter SYNC_DELAY_CLKS = 3;

  logic clk, resetn;
  logic [DATA_WIDTH-1:0] async_signal, sync_signal;

  cdc #(.DATA_WIDTH(DATA_WIDTH)) sync (
    .clk(clk),
    .resetn(resetn),
    .async_sig_i(async_signal),
    .sync_sig_o(sync_signal)
  );

  // monitor timers
  initial begin
    // initialize button state
    async_signal = 0;

    // reset
    do_reset();

    repeat (10) begin
      assert (std::randomize(async_signal));
      wait_num_clks(SYNC_DELAY_CLKS * 2);
    end

    $finish();
  end
endmodule