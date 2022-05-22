`timescale 1ns / 1ps

module an_ring_counter (
    input logic clk_10Mhz ,
    input logic reset      ,

    output logic [7:0] an_sel
);
    // Data signal declarations
    
    logic [7:0] an_sel_d, an_sel_q;
    
    always_comb begin
        if (an_sel_q[7] == 1'b1) begin // If MSB asserted, deassert and move 1 back to index 0
            an_sel_d[7] = 1'b0;
            an_sel_d[0] = 1'b1;
        end

        else begin
            an_sel_d = an_sel_q << 1'b1; // Shift to the left
        end
    end

    always_ff @ (posedge clk_10Mhz) begin
        if (reset) an_sel_q <= 8'b00000001;
        
        else an_sel_q <= an_sel_d;
    end 
    
    // Assign output
    always_comb begin
       an_sel = ~an_sel_q; // Invert to account for active low
    end
endmodule 