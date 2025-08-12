module GPU (

    input logic clk,
    input logic rst,
    /* INPUTS TO WARP DISPATCHER */
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1], // GPU TAKES IN MAX OF 8 THREADS PER SIMD CORE, AND HOLDS AT MAX 4 OF THOSE
    input logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1],
    /* INPUTS TO SIMD_CORES */
    input [31:0] instruction_from_imem, // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1], // REGISTER INITIALIZATION DATA. AKA ME FROM TESTBENCH
    

    /* OUTPUTS FROM SIMD CORES */
    output [31:0] result_out [0:THREAD_COUNT-1],
    output [31:0] pc_out_to_imem,
    output valid_instruction_out [0:THREAD_COUNT-1],

);

    /* SIGNALS FOR WARP SCHEDULER */
    logic [3:0] finished_warp_id_from_simd_core;
    logic valid_kernel_from_warp_scheduler;
    kernel_t kernel_out_from_warp_scheduler;

    // /* SIGNALS FOR WARP DISPATCHER */
    // logic [LOG2_SIMD_CORES - 1:0] simd_core_id_from_warp_dispatcher;
    // kernel_t kernel_out_from_warp_dispatcher;

warp_scheduler warp_scheduler_inst (
    .clk(clk),
    .rst(rst),
    .launch_kernel(launch_kernel),
    .num_incoming_threads(num_incoming_threads),
    .starting_pc(starting_pc),
    .finished_warp_id(finished_warp_id_from_simd_core),

    .valid_kernel(valid_kernel_from_warp_scheduler),
    .kernel_out(kernel_out_from_warp_scheduler)
);



// Per-core kernel wires (one-hot delivery from dispatcher)
kernel_t kernel_per_core [0:NUM_SIMD_CORES-1];
logic   valid_kernel_per_core [0:NUM_SIMD_CORES-1];

// Per-core status outputs (each core drives its own)
logic freed_simd_core_from_simd_core_arr [0:NUM_SIMD_CORES-1];
logic is_simd_free_arr [0:NUM_SIMD_CORES-1];


// warp dispatcher stays the same but note it still outputs single simd_core_id and kernel_out
warp_dispatcher warp_dispatcher_inst (
    .clk(clk),
    .rst(rst),
    .kernel_in(kernel_out_from_warp_scheduler),
    .valid_kernel(valid_kernel_from_warp_scheduler),
    .freed_simd_core_any(/* optional: aggregator if needed */),
    .is_simd_free_any(/* optional: aggregator if needed */),

    .simd_core_id(simd_core_id_from_warp_dispatcher),
    .kernel_out(kernel_out_from_warp_dispatcher)
);

// Masking logic: only route dispatched kernel to the selected core
// (combinational)
always_comb begin
    // default: no core gets a kernel
    for (int j = 0; j < NUM_SIMD_CORES; j = j + 1) begin
        kernel_per_core[j] = '0;                // default safe value
        valid_kernel_per_core[j] = 1'b0;
    end

    if (valid_kernel_from_warp_scheduler) begin
        // deliver to the selected core only
        int idx = simd_core_id_from_warp_dispatcher;
        if (idx >= 0 && idx < NUM_SIMD_CORES) begin
            kernel_per_core[idx] = kernel_out_from_warp_dispatcher;
            valid_kernel_per_core[idx] = 1'b1;
        end
    end
end

// instantiate SIMD cores, each receives its own kernel_in + valid_kernel_in
genvar i;
generate
    for (i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
        simd_core simd_core_inst (
            .clk(clk),
            .rst(rst),
            .kernel_in(kernel_per_core[i]),            // per-core kernel input
            .valid_kernel_in(valid_kernel_per_core[i]),// per-core valid
            .simd_core_id(i),
            .instruction_from_imem(instruction_from_imem), // if this is shared, it's fine
            .init_reg_data(init_reg_data),                 // if each core needs unique, change type
            .result_out(simd_result_out[i]),
            .pc_out_to_imem(simd_pc_out_to_imem[i]),
            .valid_instruction_out(simd_valid_instruction_out[i]),
            .freed_simd_core(freed_simd_core_from_simd_core_arr[i]),
            .is_simd_free(is_simd_free_arr[i])
        );
    end
endgenerate
    

// warp_dispatcher warp_dispatcher_inst (
//     .clk(clk),
//     .rst(rst),
//     .kernel_in(kernel_out_from_warp_scheduler),
//     .valid_kernel(valid_kernel_from_warp_scheduler),
//     .freed_simd_core(freed_simd_core_from_simd_core),
//     .is_simd_free(is_simd_free),

//     .simd_core_id(simd_core_id_from_warp_dispatcher),
//     .kernel_out(kernel_out_from_warp_dispatcher)
// );


// genvar i;
// generate
//     for (i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
//         simd_core simd_core_inst (
//             .clk(clk),
//             .rst(rst),
//             .kernel_in(kernel_out_from_warp_dispatcher),
//             .simd_core_id(i),
//             .instruction_from_imem(instruction_from_imem),
//             .init_reg_data(init_reg_data),
//             .result_out(simd_result_out[i]),
//             .pc_out_to_imem(simd_pc_out_to_imem[i]),
//             .valid_instruction_out(simd_valid_instruction_out[i]),
//             .freed_simd_core(freed_simd_core_from_simd_core),
//             .is_simd_free(is_simd_free)
//         );
//     end
// endgenerate

endmodule