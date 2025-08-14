module func_unit_tb ();

    logic clk;
    logic rst;

    logic [2:0] type_instruction;
    logic [4:0] regnum_1;
    logic [4:0] regnum_2;
    logic [4:0] dest_reg;
    logic [5:0] shammt;

    logic [31:0] init_reg_data [0:31]; // INITIAL DATA FOR THE REGISTER FILE
    logic is_active; // Indicates if the thread is active

    logic [31:0] final_result;
    logic thread_complete;

    func_unit uut (
        .clk(clk),
        .rst(rst),
        .type_instruction(type_instruction),
        .regnum_1(regnum_1),
        .regnum_2(regnum_2),
        .dest_reg(dest_reg),
        .shammt(shammt),
        .init_reg_data(init_reg_data),
        .final_result(final_result),
        .thread_complete(thread_complete),
        .is_active(is_active)
    );

    /* input logic clk,
    input logic rst,

    input logic [2:0] type_instruction,
    input logic [4:0] regnum_1,
    input logic [4:0] regnum_2,
    input logic [4:0] dest_reg,
    input logic [5:0] shammt,

    input logic [31:0] init_reg_data [0:31], // INITIAL DATA FOR THE REGISTER FILE

    output logic [31:0] final_result,
    output logic thread_complete */

    

    initial clk = 1'b1;
    always #10 clk = ~clk; // Clock generation with a period of 10 time units

    initial begin

        rst = 1'b1;
        type_instruction = 3'b111; // Example instruction type
        regnum_1 = 5'b11111; // Example register number 1
        regnum_2 = 5'b11111; // Example register number 2
        dest_reg = 5'b11111; // Example destination register
        shammt = 6'b000000; // Example shift amount
        for (int i = 0; i < 32; i = i + 1) begin
            init_reg_data[i] = 32'b0; // Initialize all registers to zero
        end
        is_active = 1'b1; // Set thread as active
        #5;

        rst = 1'b0; // Release reset
        #15;

        // FIRST, LOAD REGISTER FILE WITH INITIAL DATA
        type_instruction = 3'b110; // Load instruction
        for (int i = 0; i < 32; i = i + 1) begin
            init_reg_data[i] = i; // Load registers with initial data (0 to 31)
        end

        #20;

        type_instruction = 3'b000; // Example: Integer addition
        regnum_1 = 5'd1; // Register 1
        regnum_2 = 5'd9; // Register 2
        dest_reg = 5'd3; // Destination register 3
        #20;


        $finish;


    end



endmodule