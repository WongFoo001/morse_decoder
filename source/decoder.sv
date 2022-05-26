`timescale 1ns / 1ps

module decoder(
    input logic clk_100Mhz , // 100 MHz Clock
    input logic reset      , // Reset

    input logic       data_valid , // Data valid, clock in new data
    input logic [2:0] char_index ,
    input logic [5:0]  char_data , // Char data from receiver

    output logic [55:0]       seg // {seg7[7:0], seg6[7:0], seg5[7:0], seg4[7:0], seg3[7:0], seg2[7:0], seg1[7:0], seg0[7:0]}
    );
    
    // NOTE: Segments are active low signals!
    // Seg Order: 7b'0 0 0 0 0 0 0 
    //               G F E D C B A

    // Internal Data Declarations
    logic [6:0] seg7_d , seg7_q ,
                seg6_d , seg6_q ,
                seg5_d , seg5_q ,
                seg4_d , seg4_q ,
                seg3_d , seg3_q ,
                seg2_d , seg2_q ,
                seg1_d , seg1_q ,
                seg0_d , seg0_q ;

    // decoding logic
    always_comb begin
        // Default assignment, hold buffer values as is
        seg0_d = seg0_q;

        if (data_valid) begin // Shift in new char, decode its segments, store in buffer
            // Begin climb down morse tree
            // Switch first on index value
            case (char_index)
                3'b000: begin
                    if (char_data[0]) seg0_d = 7'b0000111; // T

                    else seg0_d = 7'b0000110; // E
                end // 3'b000:

                3'b001: begin
                    case (char_data[1:0])
                        2'b00: seg0_d = 7'b1001111; // I

                        2'b01: seg0_d = 7'b0001000; // A

                        2'b10: seg0_d = 7'b0101011; // N

                        2'b11: seg0_d = 7'b1010100; // M
                    endcase
                end // 3'b000:

                3'b010: begin
                    case (char_data[2:0])
                        3'b000: seg0_d = 7'b0010010; // S

                        3'b001: seg0_d = 7'b1000001; // U

                        3'b010: seg0_d = 7'b0101111; // R

                        3'b011: seg0_d = 7'b0000001; // W

                        3'b100: seg0_d = 7'b0100001; // D

                        3'b101: seg0_d = 7'b0001010; // K

                        3'b110: seg0_d = 7'b0010000; // G

                        3'b111: seg0_d = 7'b1000000; // O
                    endcase
                end // 3'b000:

                3'b011: begin
                    case (char_data[3:0])
                        4'b0000: seg0_d = 7'b0001001; // H

                        4'b0001: seg0_d = 7'b1010101; // V

                        4'b0010: seg0_d = 7'b0001110; // F

                        4'b0011: seg0_d = 7'b1110111; // ERR

                        4'b0100: seg0_d = 7'b1000111; // L

                        4'b0101: seg0_d = 7'b1110111; // ERR

                        4'b0110: seg0_d = 7'b0001100; // P

                        4'b0111: seg0_d = 7'b1100001; // J

                        4'b1000: seg0_d = 7'b0000011; // B

                        4'b1001: seg0_d = 7'b0110110; // X

                        4'b1010: seg0_d = 7'b1000110; // C

                        4'b1011: seg0_d = 7'b0010001; // Y

                        4'b1100: seg0_d = 7'b0100100; // Z

                        4'b1101: seg0_d = 7'b0011000; // Q

                        4'b1110: seg0_d = 7'b1110111; // ERR

                        4'b1111: seg0_d = 7'b1110111; // ERR

                    endcase
                end // 3'b000:

                3'b100: begin
                    // Will skip for now, many more ERR cases than valid char
                end // 3'b000:

                3'b101: begin  // Only occurs when space is sent!
                    seg0_d = 7'b1111111 ;
                end // 3'b000:
            endcase
        end
    end

    // decoding FFs
    always_ff @ (posedge clk_100Mhz) begin
        if (reset) seg0_q <= 7'b1111111 ;

        else seg0_q <= seg0_d;
    end

    // buffer shifting logic
    always_comb begin
        // Default assignments, hold buffer values as is 
        seg7_d = seg7_q ;
        seg6_d = seg6_q ;
        seg5_d = seg5_q ;
        seg4_d = seg4_q ;
        seg3_d = seg3_q ;
        seg2_d = seg2_q ;
        seg1_d = seg1_q ;

        if (data_valid) begin // Shift chars in buffer to the left
            seg7_d = seg6_q ;
            seg6_d = seg5_q ;
            seg5_d = seg4_q ;
            seg4_d = seg3_q ;
            seg3_d = seg2_q ;
            seg2_d = seg1_q ;
            seg1_d = seg0_q ;
        end
    end

    // shifting FFs
    always_ff @ (posedge clk_100Mhz) begin
        if (reset) begin
            seg7_q <= 7'b1111111 ;
            seg6_q <= 7'b1111111 ;
            seg5_q <= 7'b1111111 ;
            seg4_q <= 7'b1111111 ;
            seg3_q <= 7'b1111111 ;
            seg2_q <= 7'b1111111 ;
            seg1_q <= 7'b1111111 ;
        end 

        else begin
            seg7_q <= seg7_d ;
            seg6_q <= seg6_d ;
            seg5_q <= seg5_d ;
            seg4_q <= seg4_d ;
            seg3_q <= seg3_d ;
            seg2_q <= seg2_d ;
            seg1_q <= seg1_d ;
        end
    end

    // Output assignment
    always_comb begin
        seg = {seg7_q, seg6_q, seg5_q, seg4_q, seg3_q, seg2_q, seg1_q, seg0_q};
    end
endmodule
