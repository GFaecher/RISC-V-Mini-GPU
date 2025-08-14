module func_unit (
    input logic clk,
    input logic rst,

    input logic [2:0] type_instruction,
    input logic [4:0] regnum_1,
    input logic [4:0] regnum_2,
    input logic [4:0] dest_reg,
    input logic [5:0] shammt,

    input logic [31:0] init_reg_data [0:31], // INITIAL DATA FOR THE REGISTER FILE
    input logic is_active, // Indicates if the thread is active

    output logic [31:0] final_result,
    output logic thread_complete
);

    logic [31:0] register_file [0:31]; // 32 registers, each 32 bits wide

    logic [31:0] alu_in1, alu_in2;
    logic [31:0] int_result, float_result, alu_result;
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

    always_ff @(negedge clk or posedge rst) begin
        if (rst) begin
            final_result <= 32'b0;
            thread_complete <= 1'b1;
            for (int i = 0; i < 32; i = i + 1) begin
                register_file[i] <= 32'b0; // Initialize registers to zero on reset
            end
        end else begin
            if (!is_active) begin
                thread_complete <= 1'b1; // If thread is not active, mark as complete
            end else begin
                final_result <= 32'b0;
            if (type_instruction != 3'b110 && type_instruction != 3'b111) begin
                register_file[dest_reg] <= alu_result;
                final_result <= alu_result;
            end else if (type_instruction == 3'b110) begin
                for (int i = 0; i < 32; i++) begin
                    register_file[i] <= init_reg_data[i];
                end
            end
            thread_complete <= (type_instruction == 3'b111) ? 1'b1 : 1'b0;
            end
        end
    end


    always_comb begin
        alu_in1   = register_file[regnum_1];
        alu_in2   = register_file[regnum_2];
        adder_cin = 1'b0;
        alu_result = 32'b0;

        unique case (type_instruction)
            3'b000: begin // ADD
                adder_cin  = 1'b0;
                alu_result = int_result;
            end
            3'b001: begin // SUB
                alu_in2    = ~alu_in2;
                adder_cin  = 1'b1;
                alu_result = int_result;
            end
            3'b010: alu_result = alu_in1 * alu_in2;
            3'b011: alu_result = (alu_in2 != 0) ?(alu_in1 / alu_in2) : 32'hFFFFFFFF;
            3'b100: alu_result = float_result;
            3'b101: begin
                alu_in2[31] = ~alu_in2[31];
                alu_result  = float_result;
            end
            default: alu_result = 32'b0;
        endcase
    end

endmodule