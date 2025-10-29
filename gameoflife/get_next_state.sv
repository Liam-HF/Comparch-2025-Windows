module get_next_state(

    input logic[6:0] bit_index,
    input logic clk,
    input logic[63:0] temp_reg,
    output logic next_state

);
    logic[2:0] minus_x_coord;
    logic[2:0] plus_x_coord;
    logic[2:0] minus_y_coord;
    logic[2:0] plus_y_coord;
    logic[2:0] x_coord;
    logic[2:0] y_coord;
    logic[3:0] state_sum;
    //logic[2:0] x_inter;
    //logic[2:0] y_inter;
    logic[5:0] out_coord_one;
    logic[5:0] out_coord_two;
    logic[5:0] out_coord_three;
    logic[5:0] out_coord_four;
    logic[5:0] out_coord_five;
    logic[5:0] out_coord_six;
    logic[5:0] out_coord_seven;
    logic[5:0] out_coord_eight;
    logic current_state;
    //logic [23:0] dict_coord = 24'b000_001_010_011_100_101_110_111;

    always_comb begin
        x_coord = bit_index[2:0];
        y_coord = bit_index[5:3];

        minus_x_coord = (x_coord > 0) ? (x_coord - 1) : 7;
        plus_x_coord  = (x_coord < 7) ? (x_coord + 1) : 0;
        minus_y_coord = (y_coord > 0) ? (y_coord - 1) : 7;
        plus_y_coord  = (y_coord < 7) ? (y_coord + 1) : 0;


        out_coord_one = 8*minus_y_coord + minus_x_coord;
        out_coord_two = 8*minus_y_coord + x_coord;
        out_coord_three = 8*minus_y_coord + plus_x_coord;
        out_coord_four = 8*y_coord + minus_x_coord;
        out_coord_five = 8*y_coord + plus_x_coord;
        out_coord_six = 8*plus_y_coord + minus_x_coord;
        out_coord_seven = 8*plus_y_coord + x_coord;
        out_coord_eight = 8*plus_y_coord + plus_x_coord;

        state_sum = temp_reg[out_coord_eight] + temp_reg[out_coord_seven] +
        temp_reg[out_coord_six] + temp_reg[out_coord_five] + temp_reg[out_coord_four]
        + temp_reg[out_coord_three] + temp_reg[out_coord_two] + temp_reg[out_coord_one];

        current_state = temp_reg[bit_index];
    end

    always_ff@(posedge clk) begin
        if (current_state == 0) begin
            next_state <= (state_sum == 3) ? 1 : 0;
        end else begin
            next_state <= ((state_sum == 2) || (state_sum == 3)) ? 1 : 0;
        end
    end
endmodule