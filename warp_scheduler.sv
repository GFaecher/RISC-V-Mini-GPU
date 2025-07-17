include "Structs_and_Params.svh"

module warp_scheduler (
    input logic clk,
    input logic rst,
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:LOG2_SIMD_CORES - 1], // GPU TAKES IN MAX OF 8 THREADS PER SIMD CORE, AND HOLDS AT MAX 4 OF THOSE
    input logic [31:0] starting_pc [0:LOG2_SIMD_CORES - 1],

    output logic valid_kernel,
    output kernel_t kernel_out
);

    logic [15:0] open_warp_ids; // NOTE: 16 OPTIONS IS COMPLETELY ARBITRARY

    logic [31 + LOG2_THREAD_COUNT:0] thread_register [0:31]; //NOTE: 32 REGISTERS IS ARBITRARY


    always_comb begin : FILL_THREAD_REGISTER
        int i = 0;
        while (num_incoming_threads[i] != 0 && i < LOG2_SIMD_CORES) begin

            int j = 0;
            while (thread_register[j] != (31 + LOG2_THREAD_COUNT)'b0) begin
                j = j + 1; // Find the next available register
            end

            thread_register[j][31 + LOG2_THREAD_COUNT:LOG2_THREAD_COUNT] = starting_pc[i];
            thread_register[j][LOG2_THREAD_COUNT - 1:0] = num_incoming_threads[i];
            i = i + 1;
        end
    end

    always_ff @(posedge clk || posedge rst) begin

        if (rst) begin
            valid_kernel = 0;
            kernel_out.thread_count = '0;
            kernel_out.start_pc = '0;
            kernel_out.warp_id = '0;
        end else if (launch_kernel) begin
            valid_kernel = 1;
            kernel_out.thread_count = thread_register[0][LOG2_THREAD_COUNT - 1:0];
            kernel_out.start_pc = thread_register[0][31 + LOG2_THREAD_COUNT:LOG2_THREAD_COUNT];
            kernel_out.warp_id = find_warp_id(open_warp_ids);
        end
        
    end

    function logic find_warp_id(input logic [15:0] open_warp_ids);

        case open_warp_ids

            16'b0000000000000001 & open_warp_ids: return 4'b0000;
            16'b0000000000000010 & open_warp_ids: return 4'b0001;
            16'b0000000000000100 & open_warp_ids: return 4'b0010;
            16'b0000000000001000 & open_warp_ids: return 4'b0011;
            16'b0000000000010000 & open_warp_ids: return 4'b0100;
            16'b0000000000100000 & open_warp_ids: return 4'b0101;
            16'b0000000001000000 & open_warp_ids: return 4'b0110;
            16'b0000000010000000 & open_warp_ids: return 4'b0111;
            16'b0000000100000000 & open_warp_ids: return 4'b1000;
            16'b0000001000000000 & open_warp_ids: return 4'b1001;
            16'b0000010000000000 & open_warp_ids: return 4'b1010;
            16'b0000100000000000 & open_warp_ids: return 4'b1011;
            16'b0001000000000000 & open_warp_ids: return 4'b1100;
            16'b0010000000000000 & open_warp_ids: return 4'b1101;
            16'b0100000000000000 & open_warp_ids: return 4'b1110;
            16'b1000000000000000 & open_warp_ids: return 4'b1111;
            default: return 4'bXXXX; // No available warp ID

        endcase

        return 4'bXXXX; // Default case if no warp ID is found
        
    endfunction


endmodule

