`include "Structs_and_Params.svh"

module warp_dispatcher (
    input logic clk,
    input logic rst,
    input kernel_t kernel_in,
    input logic valid_kernel,
    input logic [LOG2_SIMD_CORES - 1:0] freed_simd_core, // INDICATES WHICH SIMD CORES ARE AVAILABLE

    output logic [LOG2_SIMD_CORES - 1:0] simd_core_id, // INDICATES WHICH SIMD CORES THIS KERNEL IS HEADING 
    output kernel_t kernel_out
);

    logic available_simd_cores [0:NUM_SIMD_CORES];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            available_simd_cores <= '0;
            simd_core_id <= 'hFFFFFFFF; // INVALID ID
            kernel_out.thread_count <= 0;
            kernel_out.start_pc <= 0;
            kernel_out.warp_id <= 'hFFFFFFFF; // INVALID ID
        end else begin
            if (valid_kernel) begin
                for (int i = 0; i < NUM_SIMD_CORES; i++) begin
                    if (available_simd_cores[i]) begin
                        simd_core_id <= i;
                        kernel_out <= kernel_in;
                        available_simd_cores[i] <= 1; // Mark this SIMD core as busy
                    end
                end
            end
            available_simd_cores[freed_simd_core] = 1'b0;
        end
    end
endmodule