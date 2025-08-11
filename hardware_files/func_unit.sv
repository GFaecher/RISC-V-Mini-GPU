module func_unit (
    input logic clk,
    input logic rst,
    input logic [31:0] starting_pc,

    input logic [31:0] init_mem_addr,
    input logic [31:0] init_reg_data [0:31], // INPUT FROM MEMORY. AKA ME FROM TESTBENCH

    input logic [2:0] type_instruction,
    input logic [4:0] regnum_1,
    input logic [4:0] regnum_2,
    input logic [4:0] dest_reg,
    input logic [5:0] shammt,

    output logic read_reg_mem_data,
    output logic [31:0] result,
    output logic thread_complete
);

    typedef enum logic {INIT_LOAD = 1'b0, EXECUTE = 1'b1} state_t;
    state_t curr_state, next_state;


    logic [31:0] register_file [0:31];

    logic [31:0] int_in1, int_in2;
    logic adder_cin;
    logic [31:0] float_in1, float_in2;
    logic [31:0] final_result;

    logic [31:0] prev_starting_pc;
    logic need_init;
    logic finished_init;

    add adder (
        .in0(int_in1),
        .in1(int_in2),
        .cin(adder_cin),
        .out(final_result),
        .cout()
    );

    fl32 floating_point_unit (
        .in0(float_in1),
        .in1(float_in2),
        .out(final_result)
    );


    /* LOGIC TO DETECT NEW INPUT */
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_starting_pc <= 32'h0;
        end else begin
            prev_starting_pc <= starting_pc;
        end
    end
    assign need_init = (prev_starting_pc != starting_pc);


    /* ALL STATE LOGIC */
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            INIT_LOAD: begin
                finished_init = 1;
                for (int i = 0; i < 32; i = i + 1) begin
                    if (register_file[i] != init_reg_data[i]) begin
                        finished_init = 0;
                    end
                end
                if (finished_init)
                    next_state = EXECUTE;
                else
                    next_state = INIT_LOAD;
            end
            EXECUTE: begin
                next_state = need_init ? INIT_LOAD : EXECUTE;
            end
            default: next_state = INIT_LOAD;
        endcase
    end

    /* LOTIC TO TRANSITION BETWEEN STATES */
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            curr_state <= INIT_LOAD;
        end else begin
            curr_state <= next_state;
        end
    end



    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         final_result <= 32'b0; // Reset result to zero
    //         thread_complete <= 1'b0; // Reset valid result flag
    //     end else begin
    //         thread_complete = 1'b0; // Default to invalid result
    //         final_result = 32'b0; // Default result to zero

    //         case (type_instruction)

    //             3'b000: begin // ADD
    //                 int_in1 = register_file[regnum_1];
    //                 int_in2 = register_file[regnum_2];
    //                 adder_cin = 1'b0; // No carry-in for addition
    //                 thread_complete = 1'b1;
    //             end;

    //             3'b001: begin // SUB
    //                 int_in1 = register_file[regnum_1];
    //                 int_in2 = ~(register_file[regnum_2]);
    //                 adder_cin = 1'b1;
    //                 final_result = int_in1 - int_in2;
    //                 thread_complete = 1'b1;
    //             end;

    //             3'b010: begin // MUL
    //                 int_in1 = register_file[regnum_1];
    //                 int_in2 = register_file[regnum_2];
    //                 final_result = int_in1 * int_in2; // IN FUTURE ITERATIONS, CREATE AND USE A MULTIPLIER MODULE
    //                 thread_complete = 1'b1;
    //             end;

    //             3'b011: begin // UDIV
    //                 int_in1 = register_file[regnum_1];
    //                 int_in2 = register_file[regnum_2];
    //                 if (int_in2 != 0) begin
    //                     final_result = int_in1 / int_in2; // IN FUTURE ITERATIONS, CREATE AND USE A DIVIDER MODULE
    //                 end else begin
    //                     final_result = 32'hFFFFFFFF; // Handle division by zero
    //                 end
    //                 thread_complete = 1'b1;
    //             end;

    //             3'b100: begin // FADD
    //                 float_in1 = register_file[regnum_1];
    //                 float_in2 = register_file[regnum_2];
    //                 thread_complete = 1'b1;
    //             end;

    //             3'b101: begin // FSUB
    //                 float_in1 = register_file[regnum_1];
    //                 float_in2 = register_file[regnum_2];
    //                 float_in2[31] = ~float_in2[31];
    //                 thread_complete = 1'b1;
    //             end;
    //         endcase
    //     end
    // end

endmodule