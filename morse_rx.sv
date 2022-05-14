`timescale 1ns / 1ps

module morse_rx(
    input logic clk_100MHz , // Clock
    input logic reset      , // Reset
    input logic user_btn   , // Button Signal from Debouncer

    // Timer Done Signals
    input logic btn_to     ,
    input logic dash_to    , 
    input logic inter_to   ,
    input logic word_to    ,

    // Timer Reset Signals
    output logic btn_to_res   ,
    output logic dash_to_res  ,
    output logic inter_to_res , 
    output logic word_to_res  ,  

    // Data Signals
    output logic [5:0] char_data  ,
    output logic       char_valid 
);
        
    typedef enum logic [6:0] {
        ERROR       = 7'b0000001,
        IDLE        = 7'b0000010,
        INIT_TIMERS = 7'b0000100,
        WAIT_REL    = 7'b0001000,
        DD_JUDGE    = 7'b0010000,
        INTER_CATCH = 7'b0100000,
        WORD_CATCH  = 7'b1000000
    } states_t;
    
    
    // Data Signal Declarations
    logic [4:0] char_data_d, char_data_q;
    logic [2:0] curr_data_ind_d, curr_data_ind_q; 
          // Timer data
    logic btn_to_res_d   , btn_to_res_q   , 
          dash_to_res_d  , dash_to_res_q  ,
          inter_to_res_d , inter_to_res_q , 
          word_to_res_d  , word_to_res_q  , 
          
          // Char valid data
          char_valid_d   , char_valid_q   ;
    
    // ------ Button Neg Edge Detector ------
    logic prev_button, button_neg_edge;
    always_comb begin
        // Always store prev button
        if (prev_button && !user_btn) button_neg_edge = 1'b1;

        else button_neg_edge = 1'b0;
    end

    always_ff @ (posedge clk_100MHz) begin
        if (reset) prev_button <= 1'b0;

        else prev_button <= user_btn;
    end

    // FSM State Variables
    states_t state, next_state; 

    // FSM State Transitions Logic Block
    always_comb begin
        // Mealy cheating for now
        curr_data_ind_d = curr_data_ind_q;
        
        case (state)
            // ------ State = IDLE ------
            IDLE: begin
                if (user_btn) next_state = INIT_TIMERS; // Only transitioning on a button press
                
                else next_state = IDLE;
            end

            // ------ State = INIT_TIMERS ------
            INIT_TIMERS: begin
                next_state = WAIT_REL;
            end

            // ------ State = WAIT_REL ------
            WAIT_REL: begin
                if (button_neg_edge) next_state = DD_JUDGE;

                else if (btn_to) next_state = IDLE;

                else next_state = WAIT_REL;
            end

            // ------ State = DD_JUDGE ------
            DD_JUDGE: begin
                if (inter_to) begin
                    next_state = INTER_CATCH;
                    // New letter incoming - Reset data index
                    curr_data_ind_d = 3'b0;
                end 
                
                else if (user_btn) begin
                    next_state = INIT_TIMERS;
                    curr_data_ind_d = curr_data_ind_q + 1'b1;
                end 
                
                else next_state = DD_JUDGE;
            end

            // ------ State = INTER_CATCH ------
            INTER_CATCH: begin
                if (word_to) next_state = WORD_CATCH;

                else if (user_btn) next_state = INIT_TIMERS;

                else next_state = INTER_CATCH;
            end

            // ------ State = WORD_CATCH ------
            WORD_CATCH: begin
                if (user_btn) next_state = INIT_TIMERS;

                else if (user_btn) next_state = INIT_TIMERS;

                else next_state = DD_JUDGE;
            end

            // ------ State = ERROR ------
            default: next_state = ERROR; 
        endcase
    end

    // FSM State FFs
    always_ff @ (posedge clk_100MHz) begin
        if (reset) state <= IDLE;

        else state <= next_state;
    end
   
    // FSM Data Logic Block - Completely based on state (Moore)
    always_comb begin
        // ------ Default Data Values ------
            btn_to_res_d   = 1'b0;
            dash_to_res_d  = 1'b0;
            inter_to_res_d = 1'b0;
            word_to_res_d  = 1'b0;

            char_valid_d    = 1'b0;
            char_data_d     = char_data_q; // Only changes during reset or timer catches
            
            
        case (state)
            // ------ State = IDLE ------
            IDLE: begin
                // No data change during IDLE
            end

            // ------ State = INIT_TIMERS ------
            INIT_TIMERS: begin
                // Start button timeout timer and dash timer
                btn_to_res_d  = 1'b1;
                dash_to_res_d = 1'b1;
            end

            // ------ State = WAIT_REL ------
            WAIT_REL: begin
                // Start char catch timers
                inter_to_res_d = 1'b1;
                word_to_res_d  = 1'b1;
            end

            // ------ State = DD_JUDGE ------
            DD_JUDGE: begin
                // Store curr dot or dash
                if (dash_to) char_data_d[curr_data_ind_q] = 1'b1; // If dash timer exp, store dash

                else char_data_d[curr_data_ind_q] = 1'b0; // Else store dot
            end

            // ------ State = INTER_CATCH ------
            INTER_CATCH: begin
                // Push letter onto data line and assert data valid
                char_data_d  = {1'b0, char_data_q};
                char_valid_d = 1'b1;
            end

            // ------ State = WORD_CATCH ------
            WORD_CATCH: begin
                // New Word incoming
                // Push 'space' onto data line and assert data valid
                char_data_d  = {1'b1, 5'b0};
                char_valid_d = 1'b1;
            end
        endcase
    end
    
    always_ff @ (posedge clk_100MHz) begin
        if (reset) begin
            // Timers
            btn_to_res_q   <= 1'b0;
            dash_to_res_q  <= 1'b0;
            inter_to_res_q <= 1'b0;
            word_to_res_q  <= 1'b0;
            
            // Char data
            char_valid_q    <= 1'b0;
            char_data_q     <= 5'bXXXXX;
            curr_data_ind_q <= 3'b0;
        end
        else begin
            // Timers
            btn_to_res_q   <= btn_to_res_d;
            dash_to_res_q  <= dash_to_res_d;
            inter_to_res_q <= inter_to_res_d;
            word_to_res_q  <= word_to_res_d;
            
            // Char data
            char_valid_q    <= char_valid_d;
            char_data_q     <= char_data_d;
            curr_data_ind_q <= curr_data_ind_d;
        end
    end
    
    // Assign outputs
    always_comb begin
        // Timers
        btn_to_res   = btn_to_res_q;
        dash_to_res  = dash_to_res_q;
        inter_to_res = inter_to_res_q;
        word_to_res  = word_to_res_q;

        // Char Data
        char_data  = char_data_q;
        char_valid = char_valid_q;
    end
endmodule 