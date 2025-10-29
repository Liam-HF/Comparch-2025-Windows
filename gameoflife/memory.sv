module memory #(
    parameter INIT_FILE = ""
)(
    output logic [63:0] start_data
);
    logic [63:0] file_data[0:0];
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, file_data);
            start_data <= file_data[0];
        end
    end

endmodule