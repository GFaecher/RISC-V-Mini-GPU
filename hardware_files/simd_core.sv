`include "Structs_and_Params.svh"

module simd_core (

    input clk,
    input rst,
    input kernel_t kernel_in,
    input [31:0] instruction_from_imem, // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1], // REGISTER INITIALIZATION DATA. AKA ME FROM TESTBENCH

    output is_finished_out,
    output [31:0] result_out [0:THREAD_COUNT-1],
    output [31:0] pc_out_to_imem,
    output [3:0] finished_warp_id,
    output valid_instruction_out [0:THREAD_COUNT-1] // VALID INSTRUCTION FOR EACH THREAD
);

    logic [2:0] type_instruction;
    logic [4:0] regnum_1, regnum_2, dest_reg;
    logic [5:0] shammt;
    logic thread_complete [0:THREAD_COUNT-1];
    logic [31:0] first_instruction;
    logic [31:0] pc_offset;


    always_ff @(posedge clk or posedge rst) begin // BASIC FETCHER
        if (rst) begin
            pc_out_to_imem <= 32'b0;
            valid_instruction_out <= 1'b0;
        end else begin
            // Fetch the instruction from the kernel
            pc_out_to_imem <= kernel_in.start_pc;
        end
    end

    simd_decoder decoder (
        .instruction(instruction_from_imem),
        .type_instruction(type_instruction),
        .regnum_1(regnum_1),
        .regnum_2(regnum_2),
        .dest_reg(dest_reg),
        .shammt(shammt)
    );

    genvar i;
    generate
        for (i = 0; i < THREAD_COUNT; i = i + 1) begin
            func_unit func_unit_inst (
                .clk(clk),
                .rst(rst),
                .starting_pc(kernel_in.start_pc),
                .init_mem_addr(kernel_in.start_pc), // COULD BE CHANGED IN FUTURE
                .init_reg_data(init_reg_data[i]),
                .type_instruction(type_instruction),
                .regnum_1(regnum_1),
                .regnum_2(regnum_2),
                .dest_reg(dest_reg),
                .shammt(shammt),
                .read_reg_mem_data(thread_complete[i]),
                .final_result(result_out[i]),
                .thread_complete(thread_complete[i]),
                .valid_output(valid_instruction_out[i])
            );
        end
    endgenerate

    always_comb begin
        is_finished_out = 1'b0;
        finished_warp_id = 5'b0;

        if (&thread_complete) begin
            is_finished_out = 1'b1;
            finished_warp_id = kernel_in.warp_id;
        end else begin
            is_finished_out = 1'b0;
            finished_warp_id = 4'b1111; // Indicating no warp finished
        end
    end
endmodule