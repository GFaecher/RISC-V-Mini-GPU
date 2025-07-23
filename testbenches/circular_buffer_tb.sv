`timescale 1ns / 1ps

module circular_buffer_tb ();

    typedef logic [7:0] warp_reg_t;

    logic clk, rst, push_buffer, pop_buffer, read_buffer;
    warp_reg_t data_in, data_out;
    logic at_capacity;

    circular_buffer #(
        .size(8),
        .T(warp_reg_t)
    ) uut (
        .clk(clk),
        .rst(rst),
        .push_buffer(push_buffer),
        .pop_buffer(pop_buffer),
        .read_buffer(read_buffer),
        .data_in(data_in),
        .data_out(data_out),
        .at_capacity(at_capacity)
    );
    
    // Clock generator: toggles clk every 10 time units
    initial clk = 1;
    always #10 clk = ~clk;

    initial begin
    
        rst = 1;
        push_buffer = 0;
        pop_buffer = 0;
        read_buffer = 0;
        data_in = '0;
        #5; // Wait for a clock cycle
        rst = 0; // Release reset
        #15; //low
        // Test pushing data into the buffer
        push_buffer = 1;
        data_in = 8'h01;
        #20;
        push_buffer = 0;
        data_in = 8'h02;
        #20;
        push_buffer = 1;
        data_in = 8'h03;
        #20;
        data_in = 8'h04;
        #20;
        data_in = 8'h05;
        #20;
        push_buffer = 0;
        pop_buffer = 1;
        #20;
        read_buffer = 1;
        pop_buffer = 0;
        #20;
        read_buffer = 0;
        push_buffer = 1;
        data_in = 8'h06;
        #20;
        data_in = 8'h07;
        #20;
        data_in = 8'h08;
        #20;
        push_buffer = 0;
        pop_buffer = 1;
        data_in = 8'h09;
        #20;
        pop_buffer = 0;
        push_buffer = 1;
        data_in = 8'h0A;
        #20;
        data_in = 8'h0B;
        #20;
        data_in = 8'h0C;
        #20;
        pop_buffer = 1;
        push_buffer = 0;
        data_in = 8'h0D;
        #20;
        pop_buffer = 0;
        push_buffer = 1;
        #20;
        pop_buffer = 1;
        push_buffer = 0;
        #180;

        $finish;



    end

endmodule