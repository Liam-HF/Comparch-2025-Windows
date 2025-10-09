`timescale 10ns/10ns
`include "top.sv"

module RainbowFade_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;
    logic pwm_out;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk), 
        .RGB_R            (RGB_R),
        .RGB_G            (RGB_G),
        .RGB_B            (RGB_B),
        .LED              (LED)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, RainbowFade_tb);
        #100000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
