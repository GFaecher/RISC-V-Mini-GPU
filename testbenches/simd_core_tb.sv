`include "Structs_and_Params.svh"

module simd_core_tb ();

    logic clk, rst, is_finished_out;
    kernel_t kernel_in;
    logic [31:0] instruction_from_imem, instruction_fetch, init_reg_data_fetch;
    logic [31:0] init_reg_data [THREAD_COUNT][32];
    logic [31:0] result_out [0:THREAD_COUNT-1];
    logic [3:0] finished_warp_id;

    simd_core uut (
        .clk(clk),
        .rst(rst),
        .kernel_in(kernel_in),
        .instruction_from_imem(instruction_from_imem),
        .init_reg_data(init_reg_data),
        .is_finished_out(is_finished_out),
        .result_out(result_out),
        .instruction_fetch(instruction_fetch),
        .init_reg_data_fetch(init_reg_data_fetch),
        .finished_warp_id(finished_warp_id)
    );

    /* input rst,
    input kernel_t kernel_in,
    input [31:0] instruction_from_imem, // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH. TOP LEVEL INPUT
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1], // REGISTER INITIALIZATION DATA. AKA ME FROM TESTBENCH TOP LEVEL INPUT

    output is_finished_out,
    output [31:0] result_out [0:THREAD_COUNT-1], // TOP LEVEL OUTPUT
    output [31:0] instruction_fetch, // TOP LEVEL OUTPUT
    output [31:0] init_reg_data_fetch, // TOP LEVEL OUTPUT
    output [3:0] finished_warp_id */

    initial begin clk = 1'b0; end
    always #10 clk = ~clk; // Clock generation with a period of 10 time units

    initial begin

        rst = 1'b1;
        instruction_from_imem = 32'b0; // Initialize instruction from IMEM
        for (int i = 0; i < THREAD_COUNT; i = i + 1) begin
            for (int j = 0; j < 32; j = j + 1) begin
                init_reg_data[j][i] = 32'b0; // Initialize all registers to zero
            end
        end
        kernel_in.warp_id = 4'b1111; // Initialize warp ID
        kernel_in.thread_count = 0; // Initialize thread count
        kernel_in.start_pc = 32'b0; // Initialize starting PC
        #5;
        rst = 1'b0; // Release reset
        #15;

        kernel_in.warp_id = 4'b0001; // Set warp ID for the test
        kernel_in.thread_count = 4; // Set thread count for the test
        kernel_in.start_pc = 32'h1234_5678; // Set starting PC for the test

        #60;

        $finish;
    end

endmodule