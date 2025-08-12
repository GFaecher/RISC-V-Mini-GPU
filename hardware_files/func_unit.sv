module func_unit (
    input logic clk,
    input logic rst,

    input logic [2:0] type_instruction,
    input logic [4:0] regnum_1,
    input logic [4:0] regnum_2,
    input logic [4:0] dest_reg,
    input logic [5:0] shammt,

    input logic [31:0] init_reg_data [0:31], // INITIAL DATA FOR THE REGISTER FILE

    output logic [31:0] final_result,
    output logic thread_complete,
);

    logic [31:0] register_file [0:31]; // 32 registers, each 32 bits wide

    logic [31:0] alu_in1, alu_in2;
    logic [31:0] int_result;
    logic [31:0] float_result;
    logic adder_cin;

    fl32 floating_point_unit (
        .in_0(alu_in1),
        .in_1(alu_in2),
        .out(float_result)
    );

    add #(.WIDTH(32)) integer_adder (
        .in0(alu_in1),
        .in1(alu_in2),
        .cin(adder_cin),
        .out(int_result),
        .cout()
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            final_result <= 32'b0;
            thread_complete <= 1'b1;
            for (int i = 0; i < 32; i = i + 1) begin
                register_file[i] <= 32'b0; // Initialize registers to zero on reset
            end
        end else begin
            if (type_instruciton == 3'b110) begin
                for (int i = 0; i < 32; i = i + 1) begin
                    register_file[i] <= init_reg_data[i];
                end
                thread_complete <= 1'b0;
            end else if (type_instruction == 3'b111) begin
                thread_complete <= 1'b1;
            end else begin
                register_file[dest_reg] <= final_result; // Write result to destination register
                thread_complete <= 1'b0;
            end
        end
    end


    always_comb begin

        alu_in1 = register_file[regnum_1];
        alu_in2 = register_file[regnum_2];

        case (type_instruction)

            3'b000: begin // ADD
                final_result = int_result;
                adder_cin = 1'b0; // No carry-in for addition
            end;

            3'b001: begin // SUB
                alu_in2 = ~alu_in2; // Two's complement for subtraction
                final_result = int_result;
                adder_cin = 1'b1;
            end;

            3'b010: begin // MUL
                final_result = alu_in1 * alu_in2; // IN FUTURE ITERATIONS, CREATE AND USE A MULTIPLIER MODULE
            end;

            3'b011: begin // UDIV
                if (alu_in2 != 0) begin
                    final_result = alu_in1 / alu_in2; // IN FUTURE ITERATIONS, CREATE AND USE A DIVIDER MODULE
                end else begin
                    final_result = 32'hFFFFFFFF; // Handle division by zero
                end
            end;

            3'b100: begin // FADD
                final_result = float_result;
            end;

            3'b101: begin // FSUB
                alu_in2[31] = ~alu_in2[31];
                final_result = float_result;
            end;

            3'b110: begin
                final_result = 32'b0; // LOAD INSTRUCTION, NO OPERATION HERE
            end;

            3'b111: begin // RETURN INSTRUCTION. HANDLED IN SEQUENTIAL BLOCK
                final_result = 32'b0;
            end   
        endcase  
    end

endmodule