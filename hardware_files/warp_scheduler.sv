include "Structs_and_Params.svh";

module warp_scheduler (
    input logic clk,
    input logic rst,
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1], // GPU TAKES IN MAX OF 8 THREADS PER SIMD CORE, AND HOLDS AT MAX 4 OF THOSE
    input logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1],
    input logic [3:0] finished_warp_id,

    output logic valid_kernel,
    output kernel_t kernel_out
);

    typedef enum logic [1:0] {
        LOADING_BUFFER = 2'b00;
        SENDING_KERNEL = 2'b01;
        IDLE = 2'b10;
    } state_t;

    typedef logic [31 + LOG2_THREAD_COUNT:0] warp_reg_t;

    state_t curr_state, next_state;

    logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads_buffer [0:NUM_SIMD_CORES - 1];
    logic [31:0] starting_pc_buffer [0:NUM_SIMD_CORES - 1];

    warp_reg_t data_in, data_out;

    logic [14:0] open_warp_ids; // NOTE: 15 OPTIONS IS COMPLETELY ARBITRARY

    logic [LOG2_SIMD_CORES - 1:0] i, next_i;


    logic push_buffer, pop_buffer, read_buffer, at_capacity, is_empty;

    circular_buffer #(
        .size(THREAD_COUNT), //ARBITRARY SIZE. 8
        .T(warp_reg_t)
    ) thread_register(
        .clk(clk),
        .rst(rst),
        .push_buffer(push_buffer),
        .pop_buffer(pop_buffer),
        .read_buffer(read_buffer),
        .data_in(data_in),
        .data_out(data_out),
        .at_capacity(at_capacity),
        .is_empty(is_empty)
    );

    initial begin
        valid_kernel = 0;
        kernel_out.thread_count = '0;
        kernel_out.start_pc = '0;
        kernel_out.warp_id = 4'b1111; // THE INVALID WARP ID
        read_buffer = 0;
        push_buffer = 0;
        pop_buffer = 0;
        open_warp_ids = 15'b000000000000000; // All warp IDs are initially available
    end



    case (curr_state)

        LOADING_BUFFER:
            if (launch_kernel) begin
                next_state <= SENDING_KERNEL;
            end else if (at_capacity || rst) begin
                next_state <= IDLE;
            end
            if (num_incoming_threads[i] > 0 && !at_capacity) begin
                push_buffer <= 1;
                pop_buffer <= 0;
                read_buffer <= 0;
                data_in <= {starting_pc[i], num_incoming_threads[i]}; // LOADS BUFFER
            end else begin
                data_in <= '0; // NO DATA TO LOAD
                push_buffer <= 0;
                pop_buffer <= 0;
                read_buffer <= 0; 
                next_state <= IDLE;
            end
        SENDING_KERNEL:
            pop_buffer <= 1;
            push_buffer <= 0;
            read_buffer <= 0;
            if (!at_capacity && !is_empty) begin
                valid_kernel <= 1;
                kernel_out.thread_count = data_out[LOG2_THREAD_COUNT - 1:0];
                kernel_out.start_pc = data_out[31 + LOG2_THREAD_COUNT:LOG2_THREAD_COUNT];
                kernel_out.warp_id = find_warp_id(open_warp_ids);
                open_warp_ids[kernel_out.warp_id] <= 1'b1; // Mark warp ID as used
            end

        IDLE:

            if (finished_warp_id != 4'b1111) begin
                open_warp_ids[finished_warp_id] <= 1'b0; // Mark warp ID as available
            end
            if (launch_kernel) begin
                next_state <= SENDING_KERNEL;
            end else if 


        

    endcase


    always_ff @(posedge clk or posedge rst) begin
        int i;
        for (i = 0; i < NUM_SIMD_CORES; i = i + 1) begin
            if ((num_incoming_threads[i] > 0) && !at_capacity) begin
                push_buffer <= 1;
                pop_buffer <= 0;
                read_buffer <= 0;
                data_in <= {starting_pc[i], num_incoming_threads[i]}; // LOADS BUFFER
            end
            else begin
                data_in <= '0; // NO DATA TO LOAD
                push_buffer <= 0;
                pop_buffer <= 0;
                read_buffer <= 0;
            end
        end
    end


    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            valid_kernel <= 0;
            kernel_out.thread_count <= '0;
            kernel_out.start_pc <= '0;
            kernel_out.warp_id <= '0;
        end else if (launch_kernel) begin
            pop_buffer <= 1;
            push_buffer <= 0;
            read_buffer <= 0;
            if (!at_capacity) begin
                valid_kernel <= 1;
                kernel_out.thread_count = data_out[LOG2_THREAD_COUNT - 1:0];
                kernel_out.start_pc = data_out[31 + LOG2_THREAD_COUNT:LOG2_THREAD_COUNT];
                kernel_out.warp_id = find_warp_id(open_warp_ids);
                open_warp_ids[kernel_out.warp_id] <= 1'b1; // Mark warp ID as used
            end
        end
        
    end

    function logic find_warp_id(input logic [14:0] open_warp_ids);

        case (open_warp_ids)

            !(15'b000000000000001 & open_warp_ids): return 4'b0000;
            !(15'b000000000000010 & open_warp_ids): return 4'b0001;
            !(15'b000000000000100 & open_warp_ids): return 4'b0010;
            !(15'b000000000001000 & open_warp_ids): return 4'b0011;
            !(15'b000000000010000 & open_warp_ids): return 4'b0100;
            !(15'b000000000100000 & open_warp_ids): return 4'b0101;
            !(15'b000000001000000 & open_warp_ids): return 4'b0110;
            !(15'b000000010000000 & open_warp_ids): return 4'b0111;
            !(15'b000000100000000 & open_warp_ids): return 4'b1000;
            !(15'b000001000000000 & open_warp_ids): return 4'b1001;
            !(15'b000010000000000 & open_warp_ids): return 4'b1010;
            !(15'b000100000000000 & open_warp_ids): return 4'b1011;
            !(15'b001000000000000 & open_warp_ids): return 4'b1100;
            !(15'b010000000000000 & open_warp_ids): return 4'b1101;
            !(15'b100000000000000 & open_warp_ids): return 4'b1110;
            default: return 4'b1111; // No available warp ID

        endcase

        return 4'b1111; // Default case if no warp ID is found
        
    endfunction

endmodule

