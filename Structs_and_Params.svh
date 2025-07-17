`ifndef STRUCTS_AND_PARAMS_SVH
`define STRUCTS_AND_PARAMS_SVH

// Constant declarations
parameter int THREAD_COUNT = 8; // Number of functional units per SIMD core
parameter int LOG2_THREAD_COUNT = $clog2(THREAD_COUNT);
parameter int NUM_SIMD_CORES = 4;
parameter int LOG2_SIMD_CORES = $clog2(NUM_SIMD_CORES);
parameter int MAX_THREADS = THREAD_COUNT * NUM_SIMD_CORES;
parameter int LOG2_MAX_THREADS = $clog2(MAX_THREADS);

// Struct definition
typedef struct packed {
    logic [LOG2_THREAD_COUNT-1:0] thread_count;
    logic [31:0] start_pc;
    logic [3:0] warp_id;
} kernel_t;

`endif // STRUCTS_AND_PARAMS_SVH