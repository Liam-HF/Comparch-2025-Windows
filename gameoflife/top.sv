
`include "get_next_state.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "memory.sv"

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a
);

    parameter INTERVAL = 240000;

    logic[$clog2(INTERVAL): 0] top_cycle_count = 200; // starts cycle count offset to account for delay
    logic[7:0] current_value;
    //logic [23:0] dict_coord = 24'b000_001_010_011_100_101_110_111;
    logic [5:0] indexed_bit;
    logic[2:0] x_inter;
    logic[2:0] y_inter;
    //logic[63:0] red_temp_reg = 64'b00000000_00000000_00010000_01010000_00110000_00000000_00000000_00000000;
    //logic[63:0] blue_temp_reg = 64'b11100000_00000000_00000000_00000000_01110000_00000000_00000000_00000000;
    //logic[63:0] green_temp_reg = 64'b1110000000101000000101001010000011100100111010100111001000001000;
    //logic[63:0] green_temp_reg = 64'b10000000_10000000_10000000_10000000_10000000_10000000_10000000_10000000;
    logic[63:0] red_temp_reg = 64'b0;
    logic[63:0] blue_temp_reg;
    logic[63:0] green_temp_reg;
    logic[63:0] red_start;
    logic[63:0] blue_start;
    logic[63:0] green_start;
    logic[63:0] red_new_reg = 64'b0;
    logic[63:0] blue_new_reg = 64'b0;
    logic[63:0] green_new_reg = 64'b0;
    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;
    logic[7:0] red_load_bit;
    logic[7:0] blue_load_bit;
    logic[7:0] green_load_bit;
    logic [5:0] shift_count;
    logic[5:0] advanced_bit_index;
    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;

    logic [6:0] bit_index;
    logic [3:0] state_sum;
    logic red_next_state;
    logic blue_next_state;
    logic green_next_state;
    logic ws2812b_out;

    memory #(
        .INIT_FILE      ("green.txt")
    ) u1 (
        .start_data  (green_start)
    );

    memory #(
        .INIT_FILE      ("red.txt")
    ) u2 (
        .start_data  (red_start)
    );

    memory #(
        .INIT_FILE      ("blue.txt")
    ) u3 (
        .start_data  (blue_start)
    );

    get_next_state u4 (
        .bit_index (bit_index),
        .clk (clk),
        .temp_reg (red_temp_reg),
        .next_state (red_next_state)
    );
    get_next_state u5 (
        .bit_index (bit_index),
        .clk (clk),
        .temp_reg (blue_temp_reg),
        .next_state (blue_next_state)
    );
    get_next_state u6 (
        .bit_index (bit_index),
        .clk (clk),
        .temp_reg (green_temp_reg),
        .next_state (green_next_state)
    );
    controller u7 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame)
    );
    ws2812b u8 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    initial begin
        shift_count <= 0;
        bit_index <= 0;

    end

    always_ff@(posedge clk) begin
        if (red_temp_reg == 64'b0) begin
            red_temp_reg <= red_start;
            blue_temp_reg <= blue_start;
            green_temp_reg <= green_start;
        end
        if (load_sreg) begin
            bit_index <= bit_index + 1;

            red_new_reg[bit_index] <= red_next_state;
            red_load_bit = {8{red_next_state}};
            blue_new_reg[bit_index] <= blue_next_state;
            blue_load_bit = {8{blue_next_state}};
            green_new_reg[bit_index] <= green_next_state;
            green_load_bit = {8{green_next_state}};
            shift_reg <= { green_load_bit, red_load_bit, blue_load_bit };
        end 
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
            if (bit_index >= 64) begin
                bit_index <= 0;
                advanced_bit_index <= 0;
                red_temp_reg <= red_new_reg;
                blue_temp_reg <= blue_new_reg;
                green_temp_reg <= green_new_reg;
            end 
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule