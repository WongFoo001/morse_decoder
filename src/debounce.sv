`timescale 1ns / 1ps

/*
debounce.sv:

  This module is a debouncer for a simple push-button. Debouncing
  is done by ignoring transitions shorter than 20ms.
*/

module debounce (
  input logic clk,
  input logic resetn,
  input logic raw_btn_i,

  output logic db_btn_o
);
  import morse_decoder_pkg::DEBOUNCE_THRESHOLD_C;

  logic [$clog2(DEBOUNCE_THRESHOLD_C+1)-1:0] count_r;
  logic count_en_r, db_btn_r;
  logic synced_raw_btn_r;

  // clock-domain crossing synchronizer
  cdc #(.DATA_WIDTH(1)) btn_cdc (
    .clk(clk),
    .resetn(resetn),
    .async_sig_i(raw_btn_i),
    .sync_sig_o(synced_raw_btn_r)
  );

  // count enable logic
  always_ff @ (posedge clk) begin
    if (!resetn) begin
      count_en_r <= 0;
    end

    else begin
      // raw is different state than debounced state
      if (synced_raw_btn_r != db_btn_r && count_en_r == 0) begin
        count_en_r <= 1;
      end

      // raw returned to matching debounced state OR
      // count hit debounce threshold and transition
      // was propagated.
      else if (synced_raw_btn_r == db_btn_r && count_en_r == 1) begin
        count_en_r <= 0;
      end

      // otherwise, remain unchanged
      else begin
        count_en_r <= count_en_r;
      end
    end
  end

  // debounce counter logic
  always_ff @ (posedge clk) begin
    if (!resetn) begin
      count_r <= 0;
    end

    else begin
      if (count_en_r == 1) begin
        // count up to debounce threshold
        if (count_r < DEBOUNCE_THRESHOLD_C) begin
          count_r <= count_r + 1;
        end

        // remain IDLE once threshold hit
        else begin
          count_r <= count_r;
        end
      end

      // reset count to 0
      else begin
        count_r <= 0;
      end
    end
  end

  // debounced button output driver
  always_ff @ (posedge clk) begin
    if (!resetn) begin
      db_btn_r <= 0;
    end

    else begin
      if (count_r == DEBOUNCE_THRESHOLD_C) begin
        db_btn_r <= synced_raw_btn_r;
      end

      else begin
        db_btn_r <= db_btn_r;
      end
    end
  end

  assign db_btn_o = db_btn_r;
endmodule