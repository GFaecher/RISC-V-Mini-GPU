include "Structs_and_Params.svh";

module warp_scheduler (
    input logic clk,
    input logic rst,
    input logic launch_kernel,
    input logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads [0:NUM_SIMD_CORES - 1], // GPU TAKES IN MAX OF 8 THREADS PER SIMD CORE, AND HOLDS AT MAX 4 OF THOSE
    input logic [31:0] starting_pc [0:NUM_SIMD_CORES - 1],
    input logic [3:0] finished_warp_id [0:NUM_SIMD_CORES - 1], // INDICATES WHICH WARP HAS FINISHED

    output logic valid_kernel,
    output kernel_t kernel_out
);

    typedef enum logic [1:0] {
        LOADING_BUFFER = 2'b00,
        SENDING_KERNEL = 2'b01,
        IDLE = 2'b10,
        PREPARING_KERNEL = 2'b11
    } state_t;

    typedef logic [31 + LOG2_THREAD_COUNT:0] warp_reg_t;

    state_t curr_state, next_state;

    // logic [LOG2_THREAD_COUNT - 1:0] num_incoming_threads_buffer [0:NUM_SIMD_CORES - 1];
    // logic [31:0] starting_pc_buffer [0:NUM_SIMD_CORES - 1];

    warp_reg_t data_in, data_out;

    logic [14:0] open_warp_ids; // NOTE: 15 OPTIONS IS COMPLETELY ARBITRARY

    logic [LOG2_SIMD_CORES - 1:0] i;

    logic [LOG2_THREAD_COUNT - 1:0] first_item;

    logic push_buffer, pop_buffer, read_buffer, at_capacity, is_empty;

    logic is_finished, is_finished_next;

    logic [31:0] first_pc;

    logic first_rst;

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

    always_comb begin

        case (curr_state)

        LOADING_BUFFER: begin
            data_in = '0;
            valid_kernel = 0;
            is_finished_next = is_finished;

            if (!is_finished && i < NUM_SIMD_CORES && !at_capacity) begin
                if (num_incoming_threads[i] > 0) begin
                    data_in = {starting_pc[i], num_incoming_threads[i]};
                end else begin
                    // First zero encountered: mark done
                    is_finished_next = 1;
                end
            end

            // Assign next_state based on external flags only once
            if (launch_kernel) begin
                next_state = SENDING_KERNEL;
                push_buffer = 0; // Stop pushing when not in LOADING_BUFFER state
                pop_buffer = 1; // Prepare to pop data for sending
                read_buffer = 0; // Ensure read_buffer is not active in SENDING_KERNEL state
            end else if (at_capacity || is_finished_next) begin
                next_state = IDLE;
                push_buffer = 0; // Ensure push_buffer is not active in other states
                pop_buffer = 0; // Ensure pop_buffer is not active in other states
                read_buffer = 0; // Ensure read_buffer is not active in other states
            end else begin
                next_state = LOADING_BUFFER;
                push_buffer = 1;
                pop_buffer = 0; // Ensure pop_buffer is not active in LOADING_BUFFER state
                read_buffer = 0; // Ensure read_buffer is not active in LOADING_BUFFER state
            end
        end
            
        SENDING_KERNEL: begin
            valid_kernel = 0;
            if (launch_kernel && (data_out[LOG2_THREAD_COUNT - 1:0] != '0)) begin
                valid_kernel = 1;
                kernel_out.thread_count = data_out[LOG2_THREAD_COUNT - 1:0];
                kernel_out.start_pc = data_out[31 + LOG2_THREAD_COUNT:LOG2_THREAD_COUNT];
                kernel_out.warp_id = find_warp_id(open_warp_ids);
                open_warp_ids[kernel_out.warp_id] = 1'b1;
            end
            if (launch_kernel) begin
                next_state = SENDING_KERNEL;
                push_buffer = 0; // Stop pushing when not in LOADING_BUFFER state
                pop_buffer = 1; // Prepare to pop data for sending
                read_buffer = 0; // Ensure read_buffer is not active in SENDING_KERNEL state
            end else if (at_capacity || is_finished_next) begin
                next_state = IDLE;
                push_buffer = 0; // Ensure push_buffer is not active in other states
                pop_buffer = 0; // Ensure pop_buffer is not active in other states
                read_buffer = 0; // Ensure read_buffer is not active in other states
            end else begin
                next_state = LOADING_BUFFER;
                push_buffer = 1;
                pop_buffer = 0; // Ensure pop_buffer is not active in LOADING_BUFFER state
                read_buffer = 0; // Ensure read_buffer is not active in LOADING_BUFFER state
            end
        end

        IDLE: begin
            valid_kernel = 0;
            if (launch_kernel) begin
                next_state = SENDING_KERNEL;
                push_buffer = 0; // Stop pushing when not in LOADING_BUFFER state
                pop_buffer = 1; // Prepare to pop data for sending
                read_buffer = 0; // Ensure read_buffer is not active in SENDING_KERNEL state
            end else if (at_capacity || is_finished_next) begin
                next_state = IDLE;
                push_buffer = 0; // Ensure push_buffer is not active in other states
                pop_buffer = 0; // Ensure pop_buffer is not active in other states
                read_buffer = 0; // Ensure read_buffer is not active in other states
            end else begin
                next_state = LOADING_BUFFER;
                push_buffer = 1;
                pop_buffer = 0; // Ensure pop_buffer is not active in LOADING_BUFFER state
                read_buffer = 0; // Ensure read_buffer is not active in LOADING_BUFFER state
            end
        end

        endcase
        for (int j = 0; j < NUM_SIMD_CORES; j = j + 1) begin
            if (finished_warp_id[j] != 4'b1111) begin
                open_warp_ids[finished_warp_id[j]] <= 1'b0; // Mark warp ID as available
            end
        end

        if ((i < (NUM_SIMD_CORES - 1) && !at_capacity && num_incoming_threads[i] > 0) ||
        (num_incoming_threads[0] != first_item || starting_pc[0] != first_pc)) begin
            is_finished_next = 0;
        end else begin
            is_finished_next = 1;
        end

    end


    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            curr_state <= LOADING_BUFFER;
            i <= 0;
            // valid_kernel <= 0;
            // kernel_out.thread_count <= '0;
            // kernel_out.start_pc <= '0;
            // kernel_out.warp_id <= '0;
            open_warp_ids <= 15'b000000000000000; // Reset all warp IDs to available
            data_in <= '0;
            // data_out <= '0;
            first_item <= 0;
            is_finished <= 0;
            push_buffer <= 0;
            pop_buffer <= 0;
            read_buffer <= 0;
            first_rst <= 1;

        end else begin

            if ((num_incoming_threads[0] != first_item || 
                starting_pc[0] != first_pc) && !first_rst) begin
                i <= 0; // Reset i when transitioning into LOADING_BUFFER
            end else if (!is_finished && curr_state == LOADING_BUFFER) begin
                i <= (i == (NUM_SIMD_CORES - 1)) ? i : i + 1;
            end else begin
                i <= i; // Maintain current index
            end
            first_rst <= rst;
            is_finished <= is_finished_next;
            first_item <= num_incoming_threads[0];
            first_pc <= starting_pc[0];
            curr_state <= next_state;
        end
        
    end

    function logic [3:0] find_warp_id(input logic [14:0] open_warp_ids);
        for (int i = 0; i < 15; i++) begin
            if (!open_warp_ids[i]) begin
                return i[3:0];
            end
        end
        return 4'b1111; // No available warp ID
    endfunction

endmodule
