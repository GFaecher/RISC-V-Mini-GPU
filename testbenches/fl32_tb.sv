`timescale 1ns / 1ps

module fl32_tb ();

    logic [31:0] in_0, in_1;
    logic [31:0] out;

    fl32 uut (
        .in_0(in_0),
        .in_1(in_1),
        .out(out)
    );

    initial begin
        // Test case 1: Simple addition
        in_0 = 32'b00111111100000000000000000000000;
        in_1 = 32'b01000000000000000000000000000000;
        #10;

        // Test case 2: Addition of two positive numbers with same exponent
        // 1.5 + 2.5 = 4.0
        in_0 = 32'b00111111110000000000000000000000; // 1.5
        in_1 = 32'b01000000001000000000000000000000; // 2.5
        #10;

        // Test case 3: Addition of two negative numbers
        // -1.0 + -2.0 = -3.0
        in_0 = 32'b10111111100000000000000000000000; // -1.0
        in_1 = 32'b11000000000000000000000000000000; // -2.0
        #10;

        // Test case 4: Addition of positive and negative numbers (same magnitude)
        // 2.0 + -2.0 = 0.0
        in_0 = 32'b01000000000000000000000000000000; // 2.0
        in_1 = 32'b11000000000000000000000000000000; // -2.0
        #10;

        // Test case 5: Addition of positive and negative numbers (different magnitude)
        // 5.0 + -2.0 = 3.0
        in_0 = 32'b01000000101000000000000000000000; // 5.0
        in_1 = 32'b11000000000000000000000000000000; // -2.0
        #10;

        // Test case 6: Addition with zero
        // 3.0 + 0.0 = 3.0
        in_0 = 32'b01000000010000000000000000000000; // 3.0
        in_1 = 32'b00000000000000000000000000000000; // 0.0
        #10;

        // Test case 7: Addition of two zeros
        // 0.0 + 0.0 = 0.0
        in_0 = 32'b00000000000000000000000000000000; // 0.0
        in_1 = 32'b00000000000000000000000000000000; // 0.0
        #10;

        // Test case 8: Addition of numbers with largely different exponents
        // 1e10 + 1.0 ≈ 1e10
        in_0 = 32'b01010010100101101000000000000000; // ~1e10
        in_1 = 32'b00111111100000000000000000000000; // 1.0
        #10;

        // Test case 9: Addition of same number
        // 2.0 + 2.0 = 4.0
        in_0 = 32'b01000000000000000000000000000000; // 2.0
        in_1 = 32'b01000000000000000000000000000000; // 2.0
        #10;

        // Test case 10: Addition with positive infinity
        // inf + 1.0 = inf
        in_0 = 32'b01111111100000000000000000000000; // +inf
        in_1 = 32'b00111111100000000000000000000000; // 1.0
        #10;

        // Test case 11: Addition with negative infinity
        // -inf + 1.0 = -inf
        in_0 = 32'b11111111100000000000000000000000; // -inf
        in_1 = 32'b00111111100000000000000000000000; // 1.0
        #10;

        // Test case 12: Addition of positive and negative infinity
        // +inf + -inf = NaN
        in_0 = 32'b01111111100000000000000000000000; // +inf
        in_1 = 32'b11111111100000000000000000000000; // -inf
        #10;

        // Test case 13: Addition with NaN
        // NaN + 1.0 = NaN
        in_0 = 32'b01111111110000000000000000000000; // NaN
        in_1 = 32'b00111111100000000000000000000000; // 1.0
        #10;

        // Test case 14: Addition of two NaNs
        // NaN + NaN = NaN
        in_0 = 32'b01111111110000000000000000000000; // NaN
        in_1 = 32'b01111111110000000000000000000000; // NaN
        #10;

        // Test case 15: Addition of denormalized numbers
        // Smallest positive denorm + 1.0 ≈ 1.0
        in_0 = 32'b00000000000000000000000000000001; // Smallest positive denorm
        in_1 = 32'b00111111100000000000000000000000; // 1.0
        #10;

        $finish;
    end

endmodule