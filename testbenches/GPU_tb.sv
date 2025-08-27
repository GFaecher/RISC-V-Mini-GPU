module GPU_tb();

    logic clk, rst, launch_kernel;
    logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1];
    logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1];
    logic [31:0] instruction_from_imem [0:NUM_SIMD_CORES - 1];
    logic [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1];
    logic [31:0] result_out [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1];
    logic [31:0] instruction_fetch [0:NUM_SIMD_CORES - 1];
    logic [31:0] init_reg_data_fetch [0:NUM_SIMD_CORES - 1];

    GPU uut (
        .clk(clk),
        .rst(rst),
        .launch_kernel(launch_kernel),
        .num_incoming_threads(num_incoming_threads),
        .starting_pc(starting_pc),
        .instruction_from_imem(instruction_from_imem),
        .init_reg_data(init_reg_data),
        .result_out(result_out),
        .instruction_fetch(instruction_fetch),
        .init_reg_data_fetch(init_reg_data_fetch)
    );

    initial begin clk = 1'b1; end
    always #10 clk = ~clk; // Clock generation with a period of 10 time units

/* input clk,
    input rst,
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1],
    input logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1],

    input [31:0] instruction_from_imem [0:NUM_SIMD_CORES - 1], // COMES FROM SEPARATE IMEM. AKA ME IN TESTBENCH. TOP LEVEL INPUT
    input [31:0] init_reg_data [0:31] [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1], // REGISTER INITIALIZATION DATA. AKA ME FROM TESTBENCH TOP LEVEL INPUT


    output logic [31:0] result_out [0:THREAD_COUNT-1] [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT
    output [31:0] instruction_fetch [0:NUM_SIMD_CORES - 1], // TOP LEVEL OUTPUT
    output [31:0] init_reg_data_fetch [0:NUM_SIMD_CORES - 1] // TOP LEVEL OUTPUT */

    initial begin
        rst = 1'b1;
        launch_kernel = 1'b0;
        for (int i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
            num_incoming_threads[i] = 0;
            starting_pc[i] = 0;
        end
        for (int i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
            for (int j = 0; j < THREAD_COUNT; j = j + 1) begin
                for (int k = 0; k < 32; k = k + 1) begin
                    init_reg_data[k][j][i] = 32'b0; // Initialize all registers to zero
                end
            end
        end
        #5;
        rst = 1'b0; // Release reset
        #10;
        num_incoming_threads[0] = 4; // INPUT: 3/4 LOADED BUFFER.
        starting_pc[0] = 32'h0000_000E;
        num_incoming_threads[1] = 2;
        starting_pc[1] = 32'h8765_4321;
        num_incoming_threads[2] = 7;
        starting_pc[2] = 32'hABCD_EF01;
        num_incoming_threads[3] = 3;
        starting_pc[3] = 32'h1010_1010;
        #80; // INPUT: 3/4 LOADED BUFFER.
        launch_kernel = 1; // Launch kernel with the above parameters
        #80; // Wait for the kernel to be processed
        // Cycle 1: Load instruction into first SIMD core
        instruction_from_imem[0] = 32'b10101010101111111111000000000000;
        instruction_from_imem[1] = 32'b0;
        #20;

        // Cycle 2: Load instruction into second SIMD core
        instruction_from_imem[1] = 32'b10101010101000000011000000000000;
        // Allow input of register data into first SIMD core
        for (int k = 0; k < 32; k = k + 1) begin
            for (int j = 0; j < THREAD_COUNT; j = j + 1) begin
                init_reg_data[k][j][0] = 32'h3; 
            end
        end
        #20;

        // Cycle 3: Allow input of register data into second SIMD core
        for (int k = 0; k < 32; k = k + 1) begin
            for (int j = 0; j < THREAD_COUNT; j = j + 1) begin
                init_reg_data[k][j][1] = 32'b1; 
            end
        end
        // Input another instruction into first SIMD core
        instruction_from_imem[0] = 32'b10001011000000010000000001100000;
        #20;

        // Cycle 4: Input another instruction into second SIMD core
        instruction_from_imem[1] = 32'b11001011000110010000000001100001; 
        #20;

        // Cycle 5: Input one more instruction into first SIMD core
        instruction_from_imem[0] = 32'b10011011000000010000000001100000; 
        #20;

        // Cycle 6: Input one more instruction into second SIMD core
        instruction_from_imem[1] = 32'b00011110011101010010101111111111; 
        #20;

        // Cycle 7: Input return instruction into first SIMD core
        instruction_from_imem[0] = 32'b11111111111111111111111111111111; 
        #20;

        // Cycle 8: Input return instruction into second SIMD core
        instruction_from_imem[1] = 32'b11111111111111111111111111111111;
        #100;

        $finish;

    end


endmodule