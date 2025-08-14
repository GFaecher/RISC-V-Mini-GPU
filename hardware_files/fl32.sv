module fl32 (
    input [31:0] in_0,
    input [31:0] in_1,
    output logic [31:0] out
);

    logic [7:0] exponent_0, exponent_1;

    logic [22:0] mantissa_0, mantissa_1;

    logic sign_0, sign_1;

    logic is_special_case, in0exp_eq_in1exp, in0exp_gt_in1exp, in0exp_lt_in1exp;

    logic [7:0] exponent_subtractor_in0, exponent_subtractor_in1, exponent_subtractor_out;

    logic [23:0] mantissa_shift_in, mantissa_shift_out;

    logic [23:0] mantissa_0_shifted, mantissa_1_shifted;

    logic [23:0] needed_mantissa_inverted;

    logic [23:0] mantissa_adder_in0, mantissa_adder_in1, mantissa_adder_out, mantissa_adder_cin;

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

    logic [23:0] mantissa_normalized_out;

    logic mantissa_adder_cout;


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
        .in0(exponent_subtractor_in0),
        .in1(exponent_subtractor_in1),
        .cin(1'b1),
        .out(exponent_subtractor_out),
        .cout() // cout is not used
    );

    shiftright #(.WIDTH(24)) mantissa_shifter (
        .in0(mantissa_shift_in),
        .shift_amount(exponent_subtractor_out),
        .lsr(mantissa_shift_out)
    );

    add #(.WIDTH(24)) mantissa_adder (
        .in0(mantissa_adder_in0),
        .in1(mantissa_adder_in1),
        .cin(mantissa_adder_cin),
        .out(mantissa_adder_out),
        .cout(mantissa_adder_cout) // cout is not used
    );

    // Intermediate wires for LZC and shiftleft
    logic [5:0] num_leading_zeroes_stage;
    logic found_one_stage;
    logic [23:0] mantissa_normalized_stage;

    // Instantiate Leading Zero Counter
    LZC #(.WIDTH(24)) leading_one_detector (
        .in(mantissa_adder_out),
        .count(num_leading_zeroes_stage),
        .found_one(found_one_stage)
    );

    // Instantiate shiftleft normalizer
    shiftleft #(.WIDTH(24)) mantissa_normalizer (
        .in0(mantissa_adder_out),
        .shift_amount(num_leading_zeroes_stage),
        .lsl(mantissa_normalized_stage)
    );

    add #(.WIDTH(8)) final_exponent_adjuster (
        .in0(aligned_exponent),
        .in1(8'b0),
        .cin(mantissa_adder_cout),
        .out(final_exponent),
        .cout() // cout is not used
    );

    comparator #(.WIDTH(23)) mantissa_comparator (
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
                exponent_subtractor_in0 = exponent_0;
                exponent_subtractor_in1 = ~exponent_1;
            end else if (in0exp_lt_in1exp) begin
                exponent_subtractor_in0 = exponent_1;
                exponent_subtractor_in1 = ~exponent_0;
            end else begin
                exponent_subtractor_in0 = 8'b00000000; // Equal exponents
                exponent_subtractor_in1 = 8'b11111111; // GIVES RESULT OF 0
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
                mantissa_adder_in0 = mantissa_0_shifted;
                mantissa_adder_in1 = mantissa_1_shifted;
                mantissa_adder_cin = 1'b0;
            end else begin
                if (in0exp_gt_in1exp) begin
                    mantissa_adder_in0 = mantissa_0_shifted;
                    mantissa_adder_in1 = ~mantissa_1_shifted;
                    mantissa_adder_cin = 1'b1;
                end else if (in0exp_lt_in1exp) begin
                    mantissa_adder_in0 = mantissa_1_shifted;
                    mantissa_adder_in1 = ~mantissa_0_shifted;
                    mantissa_adder_cin = 1'b1;
                end else begin
                    if (man0_gt_man1) begin
                        mantissa_adder_in0 = mantissa_0_shifted;
                        mantissa_adder_in1 = ~mantissa_1_shifted;
                        mantissa_adder_cin = 1'b1;
                    end else if (man0_lt_man1) begin
                        mantissa_adder_in0 = mantissa_1_shifted;
                        mantissa_adder_in1 = ~mantissa_0_shifted;
                        mantissa_adder_cin = 1'b1;
                    end else begin
                        mantissa_adder_in0 = 23'b0;
                        mantissa_adder_in1 = 23'b0;
                        mantissa_adder_cin = 1'b0;
                    end
                end
            end
        /* STEP 5: NORMALIZE THE RESULT */

            if (mantissa_adder_cout) begin
                final_mantissa = mantissa_adder_out[23:1]; // Shift right by 1
            end else if (found_one_stage) begin
                final_mantissa = mantissa_normalized_stage[22:0];
            end else begin
                final_mantissa = mantissa_adder_out[22:0]; // all zeros
            end

        /* STEP 6: FIND FINAL EXPONENT */

            if (in0exp_gt_in1exp) begin
                aligned_exponent = exponent_0;
            end else if (in0exp_lt_in1exp) begin
                aligned_exponent = exponent_1;
            end else begin
                aligned_exponent = exponent_0; // equal exponents
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
                        out = 32'b0; // must be 0
                    end
                end
            end
        end
    end



endmodule
