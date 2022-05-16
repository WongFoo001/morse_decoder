`timescale 1ns / 1ps

module decoder(
    input logic              clk, // 100 MHz Clock
    input logic              res, // Reset
    input logic       data_valid, // Data valid, clock in new data
    input logic [5:0]  char_data, // Char data from receiver

    output logic         new_seg,
    output logic [6:0]       seg
    );
    
    // Segment signal declarations
    logic A_d, B_d, C_d, D_d, E_d, F_d, G_d;
    logic A_q, B_q, C_q, D_q, E_q, F_q, G_q;
    
    always @ (*) begin
        case (counter)
            4'd0: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b0;
                D = 1'b0;
                E = 1'b0;
                F = 1'b0;
                G = 1'b1;
            end
            
            4'd1: begin
                A = 1'b1;
                B = 1'b0;
                C = 1'b0;
                D = 1'b1;
                E = 1'b1;
                F = 1'b1;
                G = 1'b1;
            end
            
            4'd2: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b1;
                D = 1'b0;
                E = 1'b0;
                F = 1'b1;
                G = 1'b0;
            end
            
            4'd3: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b0;
                D = 1'b0;
                E = 1'b1;
                F = 1'b1;
                G = 1'b0;
            end
            
            4'd4: begin
                A = 1'b1;
                B = 1'b0;
                C = 1'b0;
                D = 1'b1;
                E = 1'b1;
                F = 1'b0;
                G = 1'b0;
            end
            
            4'd5: begin
                A = 1'b0;
                B = 1'b1;
                C = 1'b0;
                D = 1'b0;
                E = 1'b1;
                F = 1'b0;
                G = 1'b0;
            end
            
            4'd6: begin
                A = 1'b0;
                B = 1'b1;
                C = 1'b0;
                D = 1'b0;
                E = 1'b0;
                F = 1'b0;
                G = 1'b0;
            end
            
            4'd7: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b0;
                D = 1'b1;
                E = 1'b1;
                F = 1'b1;
                G = 1'b1;
            end
            
            4'd8: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b0;
                D = 1'b0;
                E = 1'b0;
                F = 1'b0;
                G = 1'b0;
            end
            
            4'd9: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b0;
                D = 1'b0;
                E = 1'b1;
                F = 1'b0;
                G = 1'b0;
            end
            
            default begin
                A = 1'b1;
                B = 1'b1;
                C = 1'b1;
                D = 1'b1;
                E = 1'b1;
                F = 1'b1;
                G = 1'b1;
            end
        endcase
    end
    
    assign seg = {G, F, E, D, C, B, A};
endmodule
