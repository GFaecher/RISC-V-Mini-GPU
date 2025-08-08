module shiftleft #(
    parameter WIDTH = 64
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [5:0]       shift_amount, // 6 bits: max shift 0–63
    output logic [WIDTH-1:0] lsl
);

    logic [WIDTH-1:0] stage1, stage2, stage3, stage4, stage5, stage6;

    // Stage 1: shift by 1 if shift_amount[0] is set
    assign stage1 = shift_amount[0] ? {in0[WIDTH-2:0], 1'b0} : in0;

    // Stage 2: shift by 2
    assign stage2 = shift_amount[1] ? {stage1[WIDTH-3:0], 2'b0} : stage1;

    // Stage 3: shift by 4
    assign stage3 = shift_amount[2] ? {stage2[WIDTH-5:0], 4'b0} : stage2;

    // Stage 4: shift by 8
    assign stage4 = shift_amount[3] ? {stage3[WIDTH-9:0], 8'b0} : stage3;

    // Stage 5: shift by 16
    assign stage5 = shift_amount[4] ? {stage4[WIDTH-17:0], 16'b0} : stage4;

    // Stage 6: shift by 32
    assign stage6 = shift_amount[5] ? {stage5[WIDTH-33:0], 32'b0} : stage5;

    assign lsl = stage6;

endmodule
