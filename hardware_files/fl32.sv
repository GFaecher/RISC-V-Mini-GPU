module fl32 (
    input [31:0] in_0,
    input [31:0] in_1,
    output [31:0] out
);

    logic [7:0] exponent_0, exponent_1;

    logic [22:0] mantissa_0, mantissa_1;

    logic sign_0, sign_1;

    logic is_special_case, in0exp_eq_in1exp, in0exp_gt_in1exp, in0exp_lt_in1exp;

    logic [7:0] exponent_diff_in0, exponent_diff_in1, exponent_twos_complement_in0, exponent_diff_out;

    logic [23:0] mantissa_shift_in, mantissa_shift_out;

    logic [23:0] mantissa_0_shifted, mantissa_1_shifted;

    logic [23:0] needed_mantissa_inverted;

    logic [23:0] ready_mantissa_0, ready_mantissa_1, added_mantissa;

    logic final_mantissa_cout;

    logic [4:0] num_leading_zeroes;

    logic found_one;

    logic [22:0] final_mantissa;

    logic [7:0] aligned_exponent;

    logic [7:0] cout_detected_final_exponent;

    logic [7:0] final_exponent;

    logic [4:0] twos_comp_num_leading_zeroes;

    logic [7:0] adjusted_exponent;

    logic man0_gt_man1, man0_lt_man1;


    assign exponent_0 = in_0[30:23];
    assign exponent_1 = in_1[30:23];
    assign mantissa_0 = in_0[22:0];
    assign mantissa_1 = in_1[22:0];
    assign sign_0 = in_0[31];
    assign sign_1 = in_1[31];

    comparator #(.WIDTH(8)) exp_comparator(
        .a(exponent_0),
        .b(exponent_1),
        .a_eq_b(in0exp_eq_in1exp),
        .a_gt_b(in0exp_gt_in1exp),
        .a_lt_b(in0exp_lt_in1exp)
    );

    add #(.WIDTH(8)) exponent_subtractor (
        .in0(exponent_diff_in0),
        .in1(exponent_diff_in1),
        .cin(1'b1),
        .out(exponent_diff_out),
        .cout() // cout is not used
    );

    add #(.WIDTH(8)) exponent_twos_complement (
        .in0(exponent_twos_complement_in0),
        .in1(8'b00000001),
        .cin(1'b0),
        .out(exponent_diff_in1),
        .cout() // cout is not used
    );

    shiftright #(.WIDTH(24)) mantissa_shifter (
        .in0(mantissa_shift_in),
        .shift_amount(exponent_diff_out),
        .lsr(mantissa_shift_out)
    );

    add #(.WIDTH(24)) mantissa_adder (
        .in0(ready_mantissa_0),
        .in1(ready_mantissa_1),
        .cin(1'b0),
        .out(added_mantissa),
        .cout() // cout is not used
    );

    add #(.WIDTH(24)) mantissa_twos_complement (
        .in0(needed_mantissa_inverted),
        .in1(24'b1),
        .cin(1'b0),
        .out(ready_mantissa_1),
        .cout() // cout is not used
    );

    add #(.WIDTH(24)) add_mantissas (
        .in0(ready_mantissa_0),
        .in1(ready_mantissa_1),
        .cin(1'b0),
        .out(added_mantissa),
        .cout(final_mantissa_cout) // cout is not used
    );

    LZC #(.WIDTH(24)) leading_one_detector (
        .in(added_mantissa),
        .count(num_leading_zeroes),
        .found_one(found_one)
    );

    shiftleft #(.WIDTH(24)) mantissa_normalizer (
        .in0(added_mantissa),
        .shift_amount(num_leading_zeroes),
        .lsl(mantissa_shift_out)
    );

    add #(.WIDTH(8)) cout_detected_adder (
        .in0(aligned_exponent),
        .in1(8'b1),
        .cin(1'b0),
        .out(cout_detected_final_exponent),
        .cout() // cout is not used
    );

    add #(.WIDTH(5)) twos_complement_exponent_prep (
        .in0(~num_leading_zeroes),
        .in1(5'b1),
        .cin(1'b0),
        .out(twos_comp_num_leading_zeroes),
        .cout() // cout is not used
    );

    add #(.WIDTH(8)) add_exp_with_leading_zeroes (
        .in0(aligned_exponent),
        .in1(twos_comp_num_leading_zeroes),
        .cin(1'b0),
        .out(adjusted_exponent),
        .cout() // cout is not used
    );

    comparater #(.WIDTH(23)) mantissa_comparator (
        .a(mantissa_0),
        .b(mantissa_1),
        .a_eq_b(),
        .a_gt_b(man0_gt_man1),
        .a_lt_b(man0_lt_man1)
    );

    always_comb begin

        /* STEP 1: CHECK FOR SPECIAL CASES */

        if (exponent_0 == 8'hFF && mantissa_0 == 23'h0) begin //in_0 is +/- inf
            out = sign_0 ? (32'b11111111100000000000000000000000) : 
                           (32'b01111111100000000000000000000000);
            is_special_case = 1;
        end else if (exponent_1 == 8'hFF && mantissa_1 == 23'h0) begin //in_1 is +/- inf
            out = sign_1 ? (32'b11111111100000000000000000000000) : 
                           (32'b01111111100000000000000000000000);
            is_special_case = 1;
        end else if (exponent_0 == 8'hFF && mantissa_0 == 23'h40001) begin //in_0 is qNaN
            out = in_0;
            is_special_case = 1;
        end else if (exponent_1 == 8'hFF && mantissa_1 == 23'h40001) begin //in_1 is qNaN
            out = in_1;
            is_special_case = 1;
        end else if (exponent_0 == 8'hFF && mantissa_0 != 23'h0) begin //in_0 is sNaN
            out = in_0;
            is_special_case = 1;
        end else if (exponent_1 == 8'hFF && mantissa_1 != 23'h0) begin //in_1 is sNaN
            out = in_1;
            is_special_case = 1;
        end else begin
            is_special_case = 0;
        end

        /* STEP 2: COMPARE EXPONENTS */

        if (!is_special_case) begin
            if (in0exp_gt_in1exp) begin
                exponent_twos_complement_in0 = ~exponent_1;
                exponent_diff_in0 = exponent_0;
            end else if (in0exp_lt_in1exp) begin
                exponent_twos_complement_in0 = ~exponent_0;
                exponent_diff_in0 = exponent_1;
            end else begin
                exponent_twos_complement_in0 = 8'b00000000; // Equal exponents
                exponent_diff_in0 = 8'b00000000;
            end
        
        /* STEP 3: SHIFT MANTISSA OF SMALLER NUMBER BY EXPONENT DIFFERENCE */

            if (in0exp_gt_in1exp) begin
                mantissa_shift_in = {1'b1, mantissa_1};
                mantissa_0_shifted = {1'b1, mantissa_0};
                mantissa_1_shifted = mantissa_shift_out;
            end else if (in0exp_lt_in1exp) begin
                mantissa_shift_in = {1'b1, mantissa_0};
                mantissa_0_shifted = mantissa_shift_out;
                mantissa_1_shifted = {1'b1, mantissa_1};
            end else begin
                mantissa_shift_in = 23'b00000000000000000000000;
                mantissa_0_shifted = {1'b1, mantissa_0};
                mantissa_1_shifted = {1'b1, mantissa_1};
            end

        /* STEP 4: ADD THE MANTISSAS */

            if (sign_0 == sign_1) begin
                ready_mantissa_0 = mantissa_0_shifted;
                ready_mantissa_1 = mantissa_1_shifted;
            end else begin
                if (in0exp_gt_in1exp) begin
                    needed_mantissa_inverted = ~mantissa_1_shifted;
                    ready_mantissa_0 = mantissa_0_shifted;
                end else if (in0exp_lt_in1exp) begin
                    needed_mantissa_inverted = ~mantissa_0_shifted;
                    ready_mantissa_0 = mantissa_1_shifted;
                end else begin
                    needed_mantissa_inverted = 23'b0; // Equal exponents
                    ready_mantissa_0 = mantissa_0_shifted;
                end
            end
        /* STEP 5: NORMALIZE THE RESULT */

            if (found_one) begin
                final_mantissa = mantissa_shift_out[22:0];
            end else begin
                final_mantissa = added_mantissa[22:0];
            end

        /* STEP 6: FIND FINAL EXPONENT */

            if (in0exp_gt_in1exp) begin
                aligned_exponent = exponent_0;
            end else if (in0exp_lt_in1exp) begin
                aligned_exponent = exponent_1;
            end else begin
                aligned_exponent = exponent_0;
            end

            if (final_mantissa_cout) begin
                final_exponent = cout_detected_final_exponent;
            end else begin
                final_exponent = adjusted_exponent;
            end

        /* STEP 7: FIND SIGN OF NUMBER AND ASSEMBLE FINAL ANSWER*/

            if (sign_0 == sign_1) begin
                out = {sign_0, final_exponent, final_mantissa};
            end else begin
                if (in0exp_gt_in1exp) begin
                    out = {sign_0, final_exponent, final_mantissa};
                end else if (in0exp_lt_in1exp) begin
                    out = {sign_1, final_exponent, final_mantissa};
                end else begin
                    if (man0_gt_man1) begin
                        out = {sign_0, final_exponent, final_mantissa};
                    end else if (man0_lt_man1) begin
                        out = {sign_1, final_exponent, final_mantissa};
                    end else begin
                        out = 32'b0 // must be 0
                    end
                end
            end
        end else begin
            out = out;
        end
    end



endmodule
