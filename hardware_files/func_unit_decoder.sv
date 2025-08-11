module func_unit_decoder (

    input [31:0] instruction,


    output [2:0] type_instruction,
    output [4:0] regnum_1,
    output [4:0] regnum_2,
    output [4:0] dest_reg,
    output [11:0] immediate,
    output [5:0] shammt

);

/* IF OPCODE IS ___, then type_instruction is:
    ADD: 10001011000 | 000
    SUB: 11001011000 | 001
    MUL: 10011011000 | 010
   UDIV: 10011010110 | 011
   FADD: 00011110011. SHAMMT: 001010 | 100
   FSUB: 00011110011. SHAMMT: 001110 | 101


endmodule