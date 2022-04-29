module decoder(
    input logic clk_100MHz , // Clock
    input logic reset      , // Reset
    input logic user_btn   , // Button Signal from Debouncer

    // Timer Done Signals
    input logic btn_to     ,
    input logic dash_to    , 
    input logic intra_to   ,
    input logic inter_to   ,
    input logic word_to    ,

    // Timer Reset Signals
    output logic btn_to_res   ,
    output logic dash_to_res  ,
    output logic intra_to_res , 
    output logic inter_to_res , 
    output logic word_to_res  ,  

    // Data Signals
    output logic [4:0] char_data  ,
    output logic       char_valid ,
);
    
    typedef enum logic [7:0] {
        ERROR       = 7'b00000001,
        IDLE        = 7'b00000010,
        INIT_TIMERS = 7'b00000100,
        WAIT_REL    = 7'b00001000,
        DD_JUDGE    = 7'b00010000,
        INTRA_CATCH = 7'b00100000,
        INTER_CATCH = 7'b01000000,
        WORD_CATCH  = 7'b10000000
    } states_t;

    // ------ Button Neg Edge Detector ------
    logic prev_button, button_neg_edge
    always_comb begin
        // Always store prev button
        if (prev_button_q && !user_btn) button_neg_edge = 1'b1;

        else button_neg_edge = 1'b0;
    end

    always_ff @ (posedge clk) begin
        if (reset) prev_button_q <= 1'b0;

        else prev_button_q <= user_btn;
    end

    // FSM State Variables
    states_t state, next_state; 

    // FSM State Transitions Logic Block
    always_comb begin
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
                if (intra_to) next_state = INTRA_CATCH;

                else next_state = DD_JUDGE;
            end

            // ------ State = INTRA_CATCH ------
            INTRA_CATCH: begin
                if (inter_to) next_state = INTER_CATCH;

                else next_state = INTRA_CATCH;
            end

            // ------ State = INTER_CATCH ------
            INTER_CATCH: begin
                if (word_to) next_state = WORD_CATCH;

                else next_state = INTER_CATCH;
            end

            // ------ State = WORD_CATCH ------
            WORD_CATCH: begin
                if (user_btn) next_state = INIT_TIMERS;

                else next_state = DD_JUDGE;
            end

            // ------ State = ERROR ------
            default: next_state = ERROR; 
        endcase
    end

    // FSM State FFs
    always_ff @ (posedge clk) begin
        if (reset) state <= IDLE;

        else state <= next_state;
    end

    // Data Signal Declarations
    logic [4:0] char_data_d, char_data_q. curr_data_ind_d, curr_data_ind_q;

          // Timer data
    logic btn_to_res_d   , btn_to_res_q   , 
          dash_to_res_d  , dash_to_res_q  ,
          intra_to_res_d , intra_to_res_q , 
          inter_to_res_d , inter_to_res_q , 
          word_to_res_d  , word_to_res_q  , 

          // Dot or dash data
          dot_or_dash_d  , dot_or_dash_q  , // Stores whether received char is dot/dash
          
          // Char valid data
          char_valid_d   , char_valid_q   ;
      
    logic 
    // FSM Data Logic Block - Completely based on state (Moore)
    always_comb begin
        case (state)
            // ------ Default Data Values ------
            btn_to_res_d   = 1'b0;
            dash_to_res_d  = 1'b0;
            intra_to_res_d = 1'b0;
            inter_to_res_d = 1'b0;
            word_to_res_d  = 1'b0;

            char_valid_d    = 1'b0;
            char_data_d     = char_data_q; // Only changes during reset or timer catches
            curr_data_ind_d = curr_data_ind_q; // Only change during reset or timer catches

            dot_or_dash_d = dot_or_dash_q;

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
                // No data change during WAIT_REL
            end

            // ------ State = DD_JUDGE ------
            DD_JUDGE: begin
                // Store curr dot or dash
                if (dash_to) char_data_d[curr_data_ind_d] = 1'b1; // If dash timer exp, store dash

                else char_data_d[curr_data_ind_d] = 1'b0; // Else store dot

                // Start char catch timers
                intra_to_res_d = 1'b1;
                inter_to_res_d = 1'b1;
                word_to_res_d  = 1'b1;
            end

            // ------ State = INTRA_CATCH ------
            INTRA_CATCH: begin
                if (inter_to) next_state = INTER_CATCH;

                else next_state = INTRA_CATCH;
            end

            // ------ State = INTER_CATCH ------
            INTER_CATCH: begin
                if (word_to) next_state = WORD_CATCH;

                else next_state = INTER_CATCH;
            end

            // ------ State = WORD_CATCH ------
            WORD_CATCH: begin
                if (user_btn) next_state = INIT_TIMERS;

                else next_state = DD_JUDGE;
            end

            // ------ State = ERROR ------
            default: next_state = ERROR; 
        endcase
    end
    