module add #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             cin,
    output logic [WIDTH-1:0] out,
    output logic             cout
);

    logic [WIDTH-1:0] carry;

    // First bit (bit 0)
    adder FIRST_ADDER (
        .x(in0[0]),
        .y(in1[0]),
        .carry(cin),
        .out(out[0]),
        .cout(carry[0])
    );

    // Middle bits (1 to WIDTH-2)
    genvar i;
    generate
        for (i = 1; i < WIDTH-1; i = i + 1) begin
            adder GEN_ADDERS (
                .x(in0[i]),
                .y(in1[i]),
                .carry(carry[i-1]),
                .out(out[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    // Last bit (bit WIDTH-1)
    adder LAST_ADDER (
        .x(in0[WIDTH-1]),
        .y(in1[WIDTH-1]),
        .carry(carry[WIDTH-2]),
        .out(out[WIDTH-1]),
        .cout(cout)
    );

endmodule
