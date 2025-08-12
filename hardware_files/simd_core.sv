`include "Structs_and_Params.svh"

module simd_core (

    input clk,
    input rst,
    input kernel_t kernel_in,
    input [31:0] instruction_from_imem, // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH. TOP LEVEL INPUT
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1], // REGISTER INITIALIZATION DATA. AKA ME FROM TESTBENCH TOP LEVEL INPUT

    output is_finished_out,
    output [31:0] result_out [0:THREAD_COUNT-1], // TOP LEVEL OUTPUT
    output [31:0] instruction_fetch, // TOP LEVEL OUTPUT
    output [31:0] init_reg_data_fetch, // TOP LEVEL OUTPUT
    output [3:0] finished_warp_id
);

    logic stall;
    logic [2:0] type_instruction;
    logic [4:0] regnum_1, regnum_2, dest_reg;
    logic [5:0] shammt;
    logic [8:0] address;
    logic thread_complete [0:THREAD_COUNT-1];
    logic [31:0] first_instruction;
    logic [31:0] pc_offset, address_out;

    assign address_out = {23'b0, address};

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            is_finished_out <= 1'b1;
            instruction_fetch <= 32'b0;
            finished_warp_id <= 4'b1111; // Indicating no warp finished
            stall <= 1'b0;
            pc_offset <= 32'b0;
            for (int i = 0; i < THREAD_COUNT; i = i + 1) begin
                result_out[i] <= 32'b0;
                thread_complete[i] <= 1'b1; // Assume all threads are complete on reset
            end
        end else begin
            if (&thread_complete) begin
                is_finished_out <= 1'b1;
                finished_warp_id <= kernel_in.warp_id;
            end else begin
                is_finished_out <= 1'b0;
                finished_warp_id <= 4'b1111; // Indicating no warp finished
                if (stall) begin
                    stall <= 1'b0;
                end else if (type_instruction == 3'b110) begin
                    stall <= 1'b1;
                    init_reg_data_fetch <= address_out; 
                end else begin
                    // Fetch the instruction from the kernel
                    instruction_fetch <= kernel_in.start_pc + pc_offset;
                    pc_offset <= pc_offset + 4;
                end
            end
        end
    end

    simd_decoder decoder (
        .instruction(instruction_from_imem),
        .type_instruction(type_instruction),
        .regnum_1(regnum_1),
        .regnum_2(regnum_2),
        .dest_reg(dest_reg),
        .shammt(shammt),
        .address(address)
    );

    genvar i;
    generate
        for (i = 0; i < THREAD_COUNT; i = i + 1) begin
            func_unit func_unit_inst (
                .clk(clk),
                .rst(rst),
                .type_instruction(type_instruction),
                .regnum_1(regnum_1),
                .regnum_2(regnum_2),
                .dest_reg(dest_reg),
                .shammt(shammt),
                .init_reg_data(init_reg_data[:, i]),
                .final_result(result_out[i]),
                .thread_complete(thread_complete[i])
            );
        end
    endgenerate

endmodule