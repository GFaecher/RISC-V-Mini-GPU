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
    output logic [31:0] final_result,
    output logic thread_complete,
    output logic valid_output
);

    typedef enum logic {INIT_LOAD = 1'b0, EXECUTE = 1'b1} state_t;
    state_t curr_state, next_state;


    logic [31:0] register_file [0:31];

    logic adder_cin;
    logic [31:0] alu_in1, alu_in2, int_result, float_result;

    logic [31:0] prev_starting_pc;
    logic need_init;
    logic finished_init;

    add adder (
        .in0(alu_in1),
        .in1(alu_in2),
        .cin(adder_cin),
        .out(int_result),
        .cout()
    );

    fl32 floating_point_unit (
        .in0(alu_in1),
        .in1(alu_in2),
        .out(float_result)
    );


    /* LOGIC TO DETECT NEW INPUT */
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_starting_pc <= 32'h0;
        end else begin
            prev_starting_pc <= starting_pc;
        end
    end
    assign need_init = ((prev_starting_pc != starting_pc) && thread_complete);


    /* STATE TRANSITION LOGIC */
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            INIT_LOAD: begin
                finished_init = 1;
                thread_complete = 0;
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

    /* UPDATE STATE LOGIC */
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            curr_state <= INIT_LOAD;
        end else begin
            curr_state <= next_state;
        end
    end

    /* EXECUTE STATE LOGIC */
    always_comb begin

        case (curr_state)

            INIT_LOAD: begin
                read_reg_mem_data = 1'b1;
                valid_output = 1'b0;
                thread_complete = 1'b0;
                result = 32'b0;
                for (int i = 0; i < 32; i = i + 1) begin
                    register_file[i] = init_reg_data[i];
                end
            end

            EXECUTE: begin

                read_reg_mem_data = 1'b0;

                case (type_instruction)

                    3'b000: begin // ADD
                        alu_in1 = register_file[regnum_1];
                        alu_in2 = register_file[regnum_2];
                        final_result = int_result;
                        adder_cin = 1'b0; // No carry-in for addition
                        valid_output = 1'b1;
                        thread_complete = 1'b0;
                    end;

                    3'b001: begin // SUB
                        alu_in1 = register_file[regnum_1];
                        alu_in2 = ~(register_file[regnum_2]);
                        final_result = int_result;
                        adder_cin = 1'b1;
                        final_result = alu_in1 - alu_in2;
                    end;

                    3'b010: begin // MUL
                        alu_in1 = register_file[regnum_1];
                        alu_in2 = register_file[regnum_2];
                        final_result = int_result;
                        final_result = alu_in1 * alu_in2; // IN FUTURE ITERATIONS, CREATE AND USE A MULTIPLIER MODULE
                        valid_output = 1'b1;
                        thread_complete = 1'b0;
                    end;

                    3'b011: begin // UDIV
                        alu_in1 = register_file[regnum_1];
                        alu_in2 = register_file[regnum_2];
                        final_result = int_result;
                        if (alu_in2 != 0) begin
                            final_result = alu_in1 / alu_in2; // IN FUTURE ITERATIONS, CREATE AND USE A DIVIDER MODULE
                        end else begin
                            final_result = 32'hFFFFFFFF; // Handle division by zero
                        end
                        valid_output = 1'b1;
                        thread_complete = 1'b0;
                    end;

                    3'b100: begin // FADD
                        alu_in1 = register_file[regnum_1];
                        alu_in2 = register_file[regnum_2];
                        final_result = float_result;
                        valid_output = 1'b1;
                        thread_complete = 1'b0;
                    end;

                    3'b101: begin // FSUB
                        alu_in1 = register_file[regnum_1];
                        alu_in2 = register_file[regnum_2];
                        final_result = float_result;
                        alu_in2[31] = ~alu_in2[31];
                        valid_output = 1'b1;
                        thread_complete = 1'b0;
                    end;

                    3'b111: begin
                        thread_complete = 1'b1;
                        final_result = 32'b0;
                        valid_output = 1'b0;
                    end   
                endcase  
            end

            default: begin
                read_reg_mem_data = 1'b0;
                valid_output = 1'b0;
                thread_complete = 1'b0;
                result = 32'b0;
            end
        endcase
    end

    /* RESET ALL INTERNAL SIGNALS */
    always_ff @(posedge rst) begin
        for (int i = 0; i < 32; i = i + 1) begin
            register_file[i] <= 32'b0;
        end
        thread_complete <= 1'b1;
        valid_output <= 1'b0;
        result <= 32'b0;
    end

endmodule