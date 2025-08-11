module comparator #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic             a_eq_b,
    output logic             a_gt_b,
    output logic             a_lt_b
);

    logic [WIDTH-1:0] a_xor_b;
    logic       eq_temp;
    logic       gt_temp;
    logic       lt_temp;

    assign a_xor_b = a ^ b;

    // Equality: if all bits are equal, a_xor_b will be 0
    assign a_eq_b = ~|a_xor_b;

    always_comb begin
        gt_temp = 0;
        lt_temp = 0;
// Check bit WIDTH-1
if (a[WIDTH-1] != b[WIDTH-1]) begin
    gt_temp = a[WIDTH-1] & ~b[WIDTH-1];
    lt_temp = ~a[WIDTH-1] & b[WIDTH-1];
end
// Check bits from WIDTH-2 down to 0
else if (a[WIDTH-2] != b[WIDTH-2]) begin
    gt_temp = a[WIDTH-2] & ~b[WIDTH-2];
    lt_temp = ~a[WIDTH-2] & b[WIDTH-2];
end
else if (a[WIDTH-3] != b[WIDTH-3]) begin
    gt_temp = a[WIDTH-3] & ~b[WIDTH-3];
    lt_temp = ~a[WIDTH-3] & b[WIDTH-3];
end
else if (a[WIDTH-4] != b[WIDTH-4]) begin
    gt_temp = a[WIDTH-4] & ~b[WIDTH-4];
    lt_temp = ~a[WIDTH-4] & b[WIDTH-4];
end
else if (a[WIDTH-5] != b[WIDTH-5]) begin
    gt_temp = a[WIDTH-5] & ~b[WIDTH-5];
    lt_temp = ~a[WIDTH-5] & b[WIDTH-5];
end
else if (a[WIDTH-6] != b[WIDTH-6]) begin
    gt_temp = a[WIDTH-6] & ~b[WIDTH-6];
    lt_temp = ~a[WIDTH-6] & b[WIDTH-6];
end
else if (a[WIDTH-7] != b[WIDTH-7]) begin
    gt_temp = a[WIDTH-7] & ~b[WIDTH-7];
    lt_temp = ~a[WIDTH-7] & b[WIDTH-7];
end
else if (a[WIDTH-8] != b[WIDTH-8]) begin
    gt_temp = a[WIDTH-8] & ~b[WIDTH-8];
    lt_temp = ~a[WIDTH-8] & b[WIDTH-8];
end
else if (a[WIDTH-9] != b[WIDTH-9]) begin
    gt_temp = a[WIDTH-9] & ~b[WIDTH-9];
    lt_temp = ~a[WIDTH-9] & b[WIDTH-9];
end
else if (a[WIDTH-10] != b[WIDTH-10]) begin
    gt_temp = a[WIDTH-10] & ~b[WIDTH-10];
    lt_temp = ~a[WIDTH-10] & b[WIDTH-10];
end
else if (a[WIDTH-11] != b[WIDTH-11]) begin
    gt_temp = a[WIDTH-11] & ~b[WIDTH-11];
    lt_temp = ~a[WIDTH-11] & b[WIDTH-11];
end
else if (a[WIDTH-12] != b[WIDTH-12]) begin
    gt_temp = a[WIDTH-12] & ~b[WIDTH-12];
    lt_temp = ~a[WIDTH-12] & b[WIDTH-12];
end
else if (a[WIDTH-13] != b[WIDTH-13]) begin
    gt_temp = a[WIDTH-13] & ~b[WIDTH-13];
    lt_temp = ~a[WIDTH-13] & b[WIDTH-13];
end
else if (a[WIDTH-14] != b[WIDTH-14]) begin
    gt_temp = a[WIDTH-14] & ~b[WIDTH-14];
    lt_temp = ~a[WIDTH-14] & b[WIDTH-14];
end
else if (a[WIDTH-15] != b[WIDTH-15]) begin
    gt_temp = a[WIDTH-15] & ~b[WIDTH-15];
    lt_temp = ~a[WIDTH-15] & b[WIDTH-15];
end
else if (a[WIDTH-16] != b[WIDTH-16]) begin
    gt_temp = a[WIDTH-16] & ~b[WIDTH-16];
    lt_temp = ~a[WIDTH-16] & b[WIDTH-16];
end
else if (a[WIDTH-17] != b[WIDTH-17]) begin
    gt_temp = a[WIDTH-17] & ~b[WIDTH-17];
    lt_temp = ~a[WIDTH-17] & b[WIDTH-17];
end
else if (a[WIDTH-18] != b[WIDTH-18]) begin
    gt_temp = a[WIDTH-18] & ~b[WIDTH-18];
    lt_temp = ~a[WIDTH-18] & b[WIDTH-18];
end
else if (a[WIDTH-19] != b[WIDTH-19]) begin
    gt_temp = a[WIDTH-19] & ~b[WIDTH-19];
    lt_temp = ~a[WIDTH-19] & b[WIDTH-19];
end
else if (a[WIDTH-20] != b[WIDTH-20]) begin
    gt_temp = a[WIDTH-20] & ~b[WIDTH-20];
    lt_temp = ~a[WIDTH-20] & b[WIDTH-20];
end
else if (a[WIDTH-21] != b[WIDTH-21]) begin
    gt_temp = a[WIDTH-21] & ~b[WIDTH-21];
    lt_temp = ~a[WIDTH-21] & b[WIDTH-21];
end
else if (a[WIDTH-22] != b[WIDTH-22]) begin
    gt_temp = a[WIDTH-22] & ~b[WIDTH-22];
    lt_temp = ~a[WIDTH-22] & b[WIDTH-22];
end
else if (a[WIDTH-23] != b[WIDTH-23]) begin
    gt_temp = a[WIDTH-23] & ~b[WIDTH-23];
    lt_temp = ~a[WIDTH-23] & b[WIDTH-23];
end
else if (a[WIDTH-24] != b[WIDTH-24]) begin
    gt_temp = a[WIDTH-24] & ~b[WIDTH-24];
    lt_temp = ~a[WIDTH-24] & b[WIDTH-24];
end
else if (a[WIDTH-25] != b[WIDTH-25]) begin
    gt_temp = a[WIDTH-25] & ~b[WIDTH-25];
    lt_temp = ~a[WIDTH-25] & b[WIDTH-25];
end
else if (a[WIDTH-26] != b[WIDTH-26]) begin
    gt_temp = a[WIDTH-26] & ~b[WIDTH-26];
    lt_temp = ~a[WIDTH-26] & b[WIDTH-26];
end
else if (a[WIDTH-27] != b[WIDTH-27]) begin
    gt_temp = a[WIDTH-27] & ~b[WIDTH-27];
    lt_temp = ~a[WIDTH-27] & b[WIDTH-27];
end
else if (a[WIDTH-28] != b[WIDTH-28]) begin
    gt_temp = a[WIDTH-28] & ~b[WIDTH-28];
    lt_temp = ~a[WIDTH-28] & b[WIDTH-28];
end
else if (a[WIDTH-29] != b[WIDTH-29]) begin
    gt_temp = a[WIDTH-29] & ~b[WIDTH-29];
    lt_temp = ~a[WIDTH-29] & b[WIDTH-29];
end
else if (a[WIDTH-30] != b[WIDTH-30]) begin
    gt_temp = a[WIDTH-30] & ~b[WIDTH-30];
    lt_temp = ~a[WIDTH-30] & b[WIDTH-30];
end
else if (a[WIDTH-31] != b[WIDTH-31]) begin
    gt_temp = a[WIDTH-31] & ~b[WIDTH-31];
    lt_temp = ~a[WIDTH-31] & b[WIDTH-31];
end

    a_gt_b = gt_temp;
    a_lt_b = lt_temp;
end

endmodule
