`timescale 1ns / 1ps
`include "Structs_and_Params.svh"

module warp_scheduler_tb ();


    // INPUTS
    logic clk, rst, launch_kernel;
    logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1];
    logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1];
    logic [3:0] finished_warp_id;

    // OUTPUTS
    logic valid_kernel;
    kernel_t kernel_out;

    warp_scheduler uut (
        .clk(clk),
        .rst(rst),
        .launch_kernel(launch_kernel),
        .num_incoming_threads(num_incoming_threads),
        .starting_pc(starting_pc),
        .finished_warp_id(finished_warp_id),
        .valid_kernel(valid_kernel),
        .kernel_out(kernel_out)
    );
    
    // Clock generator: toggles clk every 10 time units
    initial clk = 1;
    always #10 clk = ~clk;


    initial begin
    
        int i;
        rst = 1;
        launch_kernel = 0;
        finished_warp_id = 4'b1111;
        for (i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
            num_incoming_threads[i] = 0;
            starting_pc[i] = 0;
        end
        #5; // Wait for a clock cycle
        rst = 0; // Release reset
        #15; //low
        num_incoming_threads[0] = 4; // INPUT: 3/4 LOADED BUFFER.
        starting_pc[0] = 32'hFFFF_FFFE;
        num_incoming_threads[1] = 2;
        starting_pc[1] = 32'h8765_4321;
        num_incoming_threads[2] = 7;
        starting_pc[2] = 32'hABCD_EF01;
        num_incoming_threads[3] = 0;
        starting_pc[3] = 32'h0000_0000;
        #60; // INPUT: 3/4 LOADED BUFFER.
        launch_kernel = 1; // Launch kernel with the above parameters
        #20; // Wait for the kernel to be processed
        launch_kernel = 0;
        #20; // Wait for the kernel to finish processing


        $finish;



    end

endmodule