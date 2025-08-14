module LZC #(
    parameter WIDTH = 64
)(
    input  logic [WIDTH - 1:0] in,
    output logic [$clog2(WIDTH):0] count,
    output logic found_one
);

    always_comb begin
        count = WIDTH;   // default if no 1 is found
        found_one = 0;   // default if no 1 is found

        // Scan from MSB to LSB
        for (int i = WIDTH - 1; i >= 0; i--) begin
            if (in[i] && !found_one) begin
                count = WIDTH - 1 - i;
                found_one = 1;
            end
        end
    end

endmodule
