`include "Structs_and_Params.svh"

module GPU (
    input clk,
    input rst,
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1],
    input logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1],

    input [31:0] instruction_from_imem, // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH. TOP LEVEL INPUT
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1],


    output [31:0] result_out [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT
    output [31:0] instruction_fetch [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT
    output [31:0] init_reg_data_fetch [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT

);

    logic valid_kernel_from_scheduler;
    kernel_t kernel_out_from_scheduler;

    warp_scheduler warp_scheduler_inst (
        .clk(clk),
        .rst(rst),
        .launch_kernel(launch_kernel),
        .num_incoming_threads(num_incoming_threads),
        .starting_pc(starting_pc),
        .finished_warp_id(),
        .valid_kernel(valid_kernel_from_scheduler),
        .kernel_out(kernel_out_from_scheduler)
    );

    logic [LOG2_SIMD_CORES - 1:0] simd_core_id_from_dispatcher;
    kernel_t kernel_out_from_dispatcher;

    warp_dispatcher warp_dispatcher_inst (
        .clk(clk),
        .rst(rst),
        .kernel_in(kernel_out_from_scheduler),
        .valid_kernel(valid_kernel_from_scheduler),
        .freed_simd_core(),
        .simd_core_id(simd_core_id_from_dispatcher),
        .kernel_out(kernel_out_from_dispatcher)
    );

    kernel_t core_kernel_in;
    logic [31:0] core_instruction_from_imem;
    logic [31:0] core_init_reg_data [0:31] [0:THREAD_COUNT-1];

    logic [NUM_SIMD_CORES-1:0] is_finished_out;
    logic [31:0] result_out_all [0:NUM_SIMD_CORES-1][0:THREAD_COUNT-1];
    logic [31:0] instruction_fetch_all [0:NUM_SIMD_CORES-1];
    logic [31:0] init_reg_data_fetch_all [0:NUM_SIMD_CORES-1];
    logic [3:0] finished_warp_id_all [0:NUM_SIMD_CORES-1];

    // Instantiate NUM_SIMD_CORES SIMD cores
    genvar i;
    generate
        for (i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
            simd_core simd_core_inst (
                .clk(clk),
                .rst(rst),
                .kernel_in( (simd_core_id_from_dispatcher == i) ? kernel_out_from_dispatcher : '0),
                .instruction_from_imem(core_instruction_from_imem),
                .init_reg_data(core_init_reg_data),
                .is_finished_out(is_finished_out[i]),
                .result_out(result_out_all[i]),
                .instruction_fetch(instruction_fetch_all[i]),
                .init_reg_data_fetch(init_reg_data_fetch_all[i]),
                .finished_warp_id(finished_warp_id_all[i])
            );
        end
    endgenerate

endmodule