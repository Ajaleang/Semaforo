module semaforo_fsm (
    input clk,           // Clock input
    input rst_n,         // Active-low asynchronous reset input
    input enable,        // Enable input
    output reg red,      // Output for the red LED
    output reg yellow,   // Output for the yellow LED
    output reg green,    // Output for the green LED
    output [3:0] state_out  // Output representing the current state
);

    parameter [3:0] OFF = 4'b0001,   // State encoding for OFF state
                    RED = 4'b0010,   // State encoding for RED state
                    YELLOW = 4'b0100, // State encoding for YELLOW state
                    GREEN = 4'b1000;  // State encoding for GREEN state

    reg[3:0] state;       // Current state
    reg[3:0] next_state;  // Next state to transition to
    reg[5:0] timer;       // Timer to keep track of state durations
    reg timer_clear;      // Signal to clear the timer

    // State logic
    always @(*) begin
        // Initialize values
        next_state = OFF;
        red = 0;
        yellow = 0;
        green = 0;
        timer_clear = 0;

        // State transition logic
        case (state)
            OFF : begin
                // Transition to RED when enabled
                if (enable) next_state = RED;
            end
            RED : begin
                // Set red LED and transition to YELLOW after 50 cycles
                red = 1;
                if (timer == 6'd50) begin
                    next_state = YELLOW;
                    timer_clear = 1;
                end else begin
                    next_state = RED;
                end
            end
            YELLOW : begin
                // Set yellow LED and transition to GREEN after 10 cycles
                yellow = 1;
                if (timer == 6'd10) begin
                    next_state = GREEN;
                    timer_clear = 1;
                end else begin
                    next_state = YELLOW;
                end
            end
            GREEN : begin
                // Set green LED and transition to RED after 40 cycles
                green = 1;
                if (timer == 6'd40) begin
                    next_state = RED;
                    timer_clear = 1;
                end else begin
                    next_state = GREEN;
                end
            end
            default: next_state = OFF; // Default to OFF state
        endcase

        // If not enabled, force transition to OFF
        if (!enable) begin
            next_state = OFF;
        end
    end

    // State flip-flop
    always @(posedge clk or negedge rst_n) begin
        // Synchronous reset
        if (!rst_n)
            state <= OFF;
        else
            state <= next_state;
    end

    // Output the current state
    assign state_out = state;

    // Timer logic
    always @(posedge clk or negedge rst_n) begin
        // Reset timer on reset or if timer_clear is set, or if not enabled
        if (!rst_n || (timer_clear == 1) || (!enable))
            timer <= 0;
        else if (state != OFF)
            timer <= timer + 1'b1; // Increment timer in other states
    end
endmodule
