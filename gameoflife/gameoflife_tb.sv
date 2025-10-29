`timescale 10ns/10ns
`include "top.sv"

module gameoflife_tb;

    logic clk = 0;
    logic SW = 1'b1;
    logic BOOT = 1'b1;
    logic _48b, _45a;

    top u0 (
        .clk            (clk), 
        .SW             (SW), 
        .BOOT           (BOOT), 
        ._48b           (_48b), 
        ._45a           (_45a)
    );

    initial begin
        $dumpfile("gameoflife.vcd");
        $dumpvars(0, gameoflife_tb);
        #100000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
