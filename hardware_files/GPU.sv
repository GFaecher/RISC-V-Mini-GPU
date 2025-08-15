`include "Structs_and_Params.svh"

module GPU (
    input clk,
    input rst,
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1],
    input logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1],

    input [31:0] instruction_from_imem [0:NUM_SIMD_CORES - 1], // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH. TOP LEVEL INPUT
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1], // REGISTER INITIALIZATION DATA. AKA ME FROM TESTBENCH TOP LEVEL INPUT


    output logic [31:0] result_out [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT
    output [31:0] instruction_fetch [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT
    output [31:0] init_reg_data_fetch [0:NUM_SIMD_CORES - 1] // TOP LEVEL OUTPUT

);

    // Optional: keep these if you use them elsewhere
    logic [3:0] finished_warp_id_from_simd [0:NUM_SIMD_CORES - 1];

    logic valid_kernel_from_scheduler;
    kernel_t kernel_out_from_scheduler;

    warp_scheduler warp_scheduler_inst (
        .clk(clk),
        .rst(rst),
        .launch_kernel(launch_kernel),
        .num_incoming_threads(num_incoming_threads),
        .starting_pc(starting_pc),
        .finished_warp_id(finished_warp_id_from_simd),
        .valid_kernel(valid_kernel_from_scheduler),
        .kernel_out(kernel_out_from_scheduler)
    );

    logic [LOG2_SIMD_CORES - 1:0] simd_core_id_from_dispatcher;
    kernel_t kernel_out_from_dispatcher;
    logic [NUM_SIMD_CORES-1:0] core_finished_bitmap;

    warp_dispatcher warp_dispatcher_inst (
        .clk            (clk),
        .rst            (rst),
        .kernel_in      (kernel_out_from_scheduler),
        .valid_kernel   (valid_kernel_from_scheduler),
        .freed_simd_core(core_finished_bitmap),      // <-- pass the bitmap
        .simd_core_id   (simd_core_id_from_dispatcher),
        .kernel_out     (kernel_out_from_dispatcher)
    );

    // ---- SIMD core array ----
    genvar i;
    generate
        for (i = 0; i < NUM_SIMD_CORES; i++) begin : simd_core_array
            // Local temps for the subarrays
            logic [31:0] init_reg_data_slice [0:31][0:THREAD_COUNT-1];
            logic [31:0] result_out_slice    [0:THREAD_COUNT-1];

            integer r, t;
            always_comb begin
                for (r = 0; r < 32; r++) begin
                    for (t = 0; t < THREAD_COUNT; t++) begin
                        init_reg_data_slice[r][t] = init_reg_data[r][t][i];
                    end
                end
                for (t = 0; t < THREAD_COUNT; t++) begin
                    result_out[t][i] = result_out_slice[t];
                end
            end

            simd_core simd_core_inst (
                .clk                  (clk),
                .rst                  (rst),
                .kernel_in            ((simd_core_id_from_dispatcher == i) ?
                                        kernel_out_from_dispatcher : '0),
                .instruction_from_imem(instruction_from_imem[i]),
                .init_reg_data        (init_reg_data_slice),
                .is_finished_out      (core_finished_bitmap[i]),
                .result_out           (result_out_slice),
                .instruction_fetch    (instruction_fetch[i]),
                .init_reg_data_fetch  (init_reg_data_fetch[i]),
                .finished_warp_id     (finished_warp_id_from_simd[i])
            );
        end
    endgenerate

endmodule