`timescale 1ns / 1ps

module morse_rx(
    input logic clk_100MHz , // Clock
    input logic reset      , // Reset
    input logic user_btn   , // Button Signal from Debouncer

    // Timer Done Signals
    input logic btn_to   ,
    input logic dash_to  , 
    input logic inter_to ,
    input logic word_to  ,

    // Timer Reset Signals
    output logic btn_t_res   ,
    output logic dash_t_res  ,
    output logic inter_t_res , 
    output logic word_t_res  ,  

    // Data Signals
    output logic [5:0] char_data  ,
    output logic [2:0] char_index , 
    output logic       char_valid 
);
        
    typedef enum logic [3:0] {
        ERROR         = 4'b0000 ,
        IDLE          = 4'b0001 ,
        TIMERS_1_INIT = 4'b0010 ,
        REL_CATCH     = 4'b0011 ,
        TIMERS_2_INIT = 4'b0100 ,
        DD_CATCH      = 4'b0101 ,
        CHAR_POST     = 4'b0110 ,
        CHAR_CATCH    = 4'b0111 ,
        WORD_POST     = 4'b1000 ,
        WORD_CATCH    = 4'b1001 ,
        CLEANUP       = 4'b1010 
    } states_t;

    // Internal Signal Declarations
    states_t next_state, curr_state ; // FSM state

    logic [5:0] int_char_data_d, int_char_data_q ; // Internal dot/dash buffer
    logic [2:0] int_char_ind_d , int_char_ind_q  ; // Internal buffer index

    logic char_valid_d   , char_valid_q   , // Internal char valid control signal
          cleanup_flag_d , cleanup_flag_q , // Internal control to reset dot/dash buffer and index
          btn_t_res_d    , btn_t_res_q    , // Internal btn timer reset
          dash_t_res_d   , dash_t_res_q   , // Internal dash timer reset
          inter_t_res_d  , inter_t_res_q  , // Internal interchar timer reset
          word_t_res_d   , word_t_res_q   ; // Internal word timer reset

    // FSM State Transitions Logic Block
    always_comb begin
        // Default state transition
        next_state = curr_state;

        case (curr_state) 
            ERROR: begin // Should never get here!
            end

            IDLE: begin
                if (user_btn) next_state = TIMERS_1_INIT;
            end // IDLE:

            TIMERS_1_INIT: begin
                next_state = REL_CATCH;
            end // TIMERS_1_INIT:

            REL_CATCH: begin
                if (btn_to) next_state = IDLE;

                else if (!user_btn) next_state = TIMERS_2_INIT;
            end // REL_CATCH:

            TIMERS_2_INIT: begin
                next_state = DD_CATCH;
            end // TIMERS_2_INIT:

            DD_CATCH: begin
                if (user_btn) next_state = CLEANUP;

                else if (inter_to) next_state = CHAR_POST;
            end // DD_CATCH: 

            CHAR_POST: begin
                next_state = CHAR_CATCH;
            end // CHAR_POST:

            CHAR_CATCH: begin
                if (user_btn) next_state = CLEANUP;

                else if (word_to) next_state = WORD_POST;
            end // CHAR_CATCH:

            WORD_POST: begin
                next_state = WORD_CATCH;
            end // WORD_POST:

            WORD_CATCH: begin
                if (user_btn) next_state = CLEANUP;
            end // WORD_CATCH:

            CLEANUP: begin
                next_state = TIMERS_1_INIT;
            end // CLEANUP:

            default: begin // Should never get here either!
            end
        endcase
    end

    // FSM State FFs
    always_ff @ (posedge clk_100MHz) begin
        if (reset) curr_state <= IDLE; // Reset State

        else curr_state <= next_state; // Transition to next state
    end
   
    // Data Logic Block 
    always_comb begin
        // Default data assignments
        int_char_data_d = int_char_data_q ;
        int_char_ind_d  = int_char_ind_q  ;
        char_valid_d    = 1'b0            ;
        cleanup_flag_d  = 1'b0            ;

        btn_t_res_d   = 1'b0;
        dash_t_res_d  = 1'b0;
        inter_t_res_d = 1'b0;
        word_t_res_d  = 1'b0;

        case (curr_state)
            ERROR: begin // Should never get here!
            end

            IDLE: begin
            end // IDLE:

            TIMERS_1_INIT: begin
                // Assert btn timer and dash timer resets
                btn_t_res_d  = 1'b1;
                dash_t_res_d = 1'b1;
            end // TIMERS_1_INIT:

            REL_CATCH: begin
            end // REL_CATCH:

            TIMERS_2_INIT: begin
                // Assert btn inter char timer and word timer resets
                inter_t_res_d = 1'b1;
                word_t_res_d  = 1'b1;

                // Insert new dash/dot into char buffer at current index
                if (dash_to) int_char_data_d[int_char_ind_q] = 1'b1; // 1 for dash

                else int_char_data_d[int_char_ind_q] = 1'b0; // 0 for dot
            end // TIMERS_2_INIT:

            DD_CATCH: begin
                // Assert cleanup flag
                cleanup_flag_d = 1'b1;
            end // DD_CATCH: 

            CHAR_POST: begin
                // Assert char valid
                char_valid_d = 1'b1;
            end // CHAR_POST:

            CHAR_CATCH: begin
            end // CHAR_CATCH:

            WORD_POST: begin
                // Post space to char data line
                int_char_data_d = {1'b1, 5'b00000};
                int_char_ind_d  = {3'b101}; // Index of 5 -> Signals space

                // Assert char valid 
                char_valid_d = 1'b1;
            end // WORD_POST:

            WORD_CATCH: begin

            end // WORD_CATCH:

            CLEANUP: begin
                // If cleanup flag asserted, reset internal char buffer and index
                if (!cleanup_flag_q) begin
                    int_char_data_d = 6'b000000;
                    int_char_ind_d  = 3'b0;
                end

                // If not asserted, simply increment index
                else int_char_ind_d  = int_char_ind_q + 1'b1;
            end // CLEANUP:

            default: begin // Should never get here either!
            end
        endcase
    end
    
    // Data Logic FFs
    always_ff @ (posedge clk_100MHz) begin
        if (reset) begin
            int_char_data_q <= 6'b000000 ;
            int_char_ind_q  <= 3'b0      ;
            char_valid_q    <= 1'b0      ;
            cleanup_flag_q  <= 1'b0      ;

            btn_t_res_q   <= 1'b0 ;
            dash_t_res_q  <= 1'b0 ;
            inter_t_res_q <= 1'b0 ;
            word_t_res_q  <= 1'b0 ;
        end 

        else begin
            int_char_data_q <= int_char_data_d ;
            int_char_ind_q  <= int_char_ind_d  ;
            char_valid_q    <= char_valid_d    ;
            cleanup_flag_q  <= cleanup_flag_d  ;

            btn_t_res_q   <= btn_t_res_d   ;
            dash_t_res_q  <= dash_t_res_d  ;
            inter_t_res_q <= inter_t_res_d ;
            word_t_res_q  <= word_t_res_d  ;
        end
    end
    
    // Output assignment block
    always_comb begin
        char_data  = int_char_data_q ;
        char_index = int_char_ind_q  ;
        char_valid = char_valid_q    ;

        btn_t_res   = btn_t_res_q   ;
        dash_t_res  = dash_t_res_q  ;
        inter_t_res = inter_t_res_q ;
        word_t_res  = word_t_res_q  ; 
    end
endmodule 