`include "Structs_and_Params.svh"

module warp_dispatcher (
    input  logic clk,
    input  logic rst,
    input  kernel_t kernel_in,
    input  logic valid_kernel,
    input  logic [NUM_SIMD_CORES-1:0] freed_simd_core, // INDICATES WHICH SIMD CORES ARE AVAILABLE

    output logic [LOG2_SIMD_CORES - 1:0] simd_core_id, // INDICATES WHICH SIMD CORES THIS KERNEL IS HEADING 
    output kernel_t kernel_out
);

    logic [NUM_SIMD_CORES-1:0] available_simd_cores;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            available_simd_cores <= '1; // All cores available
            simd_core_id <= '0;
            kernel_out.thread_count <= '0;
            kernel_out.start_pc <= 32'b0;
            kernel_out.warp_id <= '0;
        end else begin
            // Update available cores with newly freed ones
            available_simd_cores <= available_simd_cores | freed_simd_core;

            // Default outputs: no assignment if no valid kernel or no core available
            simd_core_id <= '0;
            kernel_out <= '{default: '0};

            if (valid_kernel) begin
                // Find first available core
                for (int i = 0; i < NUM_SIMD_CORES; i++) begin
                    if (available_simd_cores[i]) begin
                        simd_core_id <= i;
                        kernel_out <= kernel_in;
                        available_simd_cores[i] <= 1'b0; // Mark as busy
                        break; // Stop after first available core
                    end
                end
            end
        end
    end
endmodule