// generate clock
clk_gen gen(
  .clk_o(clk)
);

task wait_num_clks(longint unsigned num);
  repeat (num) @(posedge clk);
endtask

task do_reset();
  resetn = 1;
  wait_num_clks(1);
  resetn = 0;
  wait_num_clks(1);
  resetn = 1;
  wait_num_clks(1);
endtask
