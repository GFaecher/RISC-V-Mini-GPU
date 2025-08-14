module shiftleft #(
    parameter WIDTH = 64
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [5:0]       shift_amount,
    output logic [WIDTH-1:0] lsl
);

    logic [WIDTH-1:0] stage1, stage2, stage3, stage4, stage5, stage6;

    // Stage 1: shift by 1
    assign stage1 = shift_amount[0] ?
                    {in0[0 +: WIDTH-1], 1'b0} :
                    in0;

    // Stage 2: shift by 2
    assign stage2 = shift_amount[1] ?
                    {stage1[0 +: WIDTH-2], 2'b0} :
                    stage1;

    // Stage 3: shift by 4
    assign stage3 = shift_amount[2] ?
                    {stage2[0 +: WIDTH-4], 4'b0} :
                    stage2;

    // Stage 4: shift by 8
    assign stage4 = shift_amount[3] ?
                    {stage3[0 +: WIDTH-8], 8'b0} :
                    stage3;

    // Stage 5: shift by 16
    assign stage5 = shift_amount[4] ?
                    {stage4[0 +: WIDTH-16], 16'b0} :
                    stage4;

    // Stage 6: shift by 32
    assign stage6 = shift_amount[5] ?
                    {stage5[0 +: WIDTH-32], 32'b0} :
                    stage5;

    assign lsl = stage6;

endmodule
