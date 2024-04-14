module debounce_tb();
  `include "stim_utilities.svh"

  logic resetn;
  logic btn_i, btn_o;
  // Not usable with xsim T.T
  event btn_toggle;

  debounce dut (
    .clk(clk),
    .resetn(resetn),
    .raw_btn_i(btn_i),
    .db_btn_o(btn_o)
  );

  task generate_bounces();
    // random number of bouncing oscillations
    automatic int unsigned num_bounces;
    assert (
      std::randomize(num_bounces) with {
        num_bounces > 10;
        num_bounces < 15;
      }
    );

    for (int i = 0; i < num_bounces; i++) begin
      btn_i = ~btn_i;
      wait_num_clks(100 - (7 * i));
    end
  endtask

  task press_btn();
    generate_bounces();
    btn_i = 1;
    wait_num_clks(1);
  endtask

  task release_btn();
    generate_bounces();
    btn_i = 0;
    wait_num_clks(1);
  endtask

  /*
  * testbench stimulus
  */
  initial begin
    // initialize button state
    btn_i = 0;

    // reset
    do_reset();
    
    // a bunch of random button presses
    begin
      automatic int unsigned num_toggles;
      assert (
        std::randomize(num_toggles) with {
          num_toggles > 10;
          num_toggles < 30;
        }
      );

      repeat (num_toggles) begin
        -> btn_toggle;
        press_btn();
        wait_num_clks(500);
        -> btn_toggle;
        release_btn();
        wait_num_clks(500);
      end
    end

    $finish();
  end
endmodule