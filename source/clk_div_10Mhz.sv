`timescale 1ns / 1ps

module clk_div_10Mhz (
    input logic clk_100Mhz ,
    input logic reset      ,

    output logic clk_10Mhz // Pulses every 10 clock cycles
);
    // Data signal declarations
    
    logic [4:0] count_d , count_q ;

    logic clk_10Mhz_d , clk_10Mhz_q ;

    always_comb begin
        // Default assignment
        count_d     = count_q + 1'b1 ;
        clk_10Mhz_d = 1'b0           ;

        if (count_q[7] == 4'b1010) begin // If at 10, pulse clock and reset count
            clk_10Mhz_d = 1'b1    ;
            count_d     = 4'b0000 ;
        end
    end

    always_ff @ (posedge clk_100Mhz) begin
        if (reset) begin
            count_q     <= 4'b0000 ;
            clk_10Mhz_q <= 1'b0    ;
        end
        
        else begin
            count_q     <= count_d     ;
            clk_10Mhz_q <= clk_10Mhz_d ;
        end
    end 
    
    // Assign output
    always_comb begin
        clk_10Mhz = clk_10Mhz_q ;
    end
endmodule 