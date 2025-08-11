module simd_decoder (

    input [31:0] instruction,


    output [2:0] type_instruction,
    output [4:0] regnum_1,
    output [4:0] regnum_2,
    output [4:0] dest_reg,
    // output [11:0] immediate, IN FUTURE VERSIONS, INCLUDE IMMEDIATE INSTRUCTIONS
    output [5:0] shammt

);

    always_comb begin

        if (instruction[31:21] == 11'b10001011000) begin
            type_instruction = 3'b000; // ADD instruction
        end else if (instruction[31:21] == 11'b11001011000) begin
            type_instruction = 3'b001; // SUB instruction
        end else if (instruction[31:21] == 11'b10011011000) begin
            type_instruction = 3'b010; // MUL instruction
        end else if (instruction[31:21] == 11'b10011010110) begin
            type_instruction = 3'b011; // UDIV instruction
        end else if (instruction[31:21] == 11'b00011110011 && instruction[15:10] == 6'b001010) begin
            type_instruction = 3'b100; // FADD instruction
        end else if (instruction[31:21] == 11'b00011110011 && instruction[15:10] == 6'b001110) begin
            type_instruction = 3'b101; // FSUB instruction
        end else begin
            type_instruction = 3'b111; // Return Instruction
        end

        dest_reg = instruction[4:0];
        regnum_1 = instruction[9:5];
        regnum_2 = instruction[20:16];
        shammt = instruction[15:10]; // Extracting the shift amount. USEFUL FOR LSL INSTRUCTIONS

    end


/* IF OPCODE IS ___, then type_instruction is:
    ADD: 10001011000 | 000
    SUB: 11001011000 | 001
    MUL: 10011011000 | 010
   UDIV: 10011010110 | 011
   FADD: 00011110011. SHAMMT: 001010 | 100
   FSUB: 00011110011. SHAMMT: 001110 | 101
*/

endmodule