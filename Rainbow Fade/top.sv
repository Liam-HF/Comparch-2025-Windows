`include "fade.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200,       // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter STATE_INTERVAL = 2000000 // CLK is 12 MHz, so 2 million cycles is 1/6 seconds
)(
    input logic     clk,  // Define RGB outputs
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value; // Define the interval PWM changes at
    logic pwm_out; // gets pwm_out from pwm module
    logic [2:0] select_bit = 3'b000; // Defines 3 bit select signal that 
    logic A = 1'b0; // Defines A
    logic [$clog2(STATE_INTERVAL) - 1:0] state_count = 0; // Defines the state count


    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .pwm_value      (pwm_value)
    ); // Imports values from fade module

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    ); // Imports values from pwm module

    initial begin
        RGB_R <= 1'b0;
        RGB_G <= 1'b1;
        RGB_B <= 1'b1;
    end // sets LED initial values

    always_ff@(posedge clk) begin
        if (state_count == STATE_INTERVAL - 1) begin
            state_count <= 0;
            if (select_bit < 3'b101) begin
                select_bit <= select_bit + 1;
            end else begin
                select_bit <= 3'b000;
            end
        end else begin
            state_count <= state_count + 1;
            if (select_bit == 3'b000) begin
                RGB_R <= A;
                RGB_G <= ~pwm_out;
                RGB_B <= ~A;
            end else if (select_bit == 3'b001) begin
                RGB_R <= ~pwm_out;
                RGB_G <= A;
                RGB_B <= ~A;
            end else if(select_bit == 3'b010) begin
                RGB_R <= ~A;
                RGB_G <= A;
                RGB_B <= ~pwm_out;
            end else if(select_bit == 3'b011) begin
                RGB_R <= ~A;
                RGB_G <= ~pwm_out;
                RGB_B <= A;
            end else if(select_bit == 3'b100) begin
                RGB_R <= ~pwm_out;
                RGB_G <= ~A;
                RGB_B <= A;
            end else if(select_bit == 3'b101) begin
                RGB_R <= A;
                RGB_G <= ~A;
                RGB_B <= ~pwm_out;
            end
        end
    end //Multiplexor for each LED to determine value based on select bit.

endmodule
