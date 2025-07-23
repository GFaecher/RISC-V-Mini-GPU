module circular_buffer #(

    parameter size = 16,
    parameter type T = logic
) (

    input logic clk, rst, push_buffer, pop_buffer, read_buffer,

    input T data_in,

    output T data_out,
    output logic at_capacity, is_empty
);
    logic [$clog2(size) - 1:0] beginning_ptr, end_ptr;
    logic is_full;


    T buffer[0:size - 1];

    initial begin
        beginning_ptr = 0;
        end_ptr = 0;
        at_capacity = 0;
        for (int i = 0; i < size; i = i + 1) begin
            buffer[i] <= '0;
        end
        data_out = '0;
        is_empty = 1;
    end

    assign is_full = beginning_ptr == end_ptr;
    assign at_capacity = is_full && !is_empty;
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            beginning_ptr <= 0;
            end_ptr <= 0;
            for (int i = 0; i < size; i = i + 1) begin
                buffer[i] <= '0;
            end
            at_capacity <= 0;
            is_empty <= 1;
        end else if (push_buffer && !pop_buffer && !read_buffer) begin
            if (!is_full || is_empty) begin
                buffer[end_ptr] <= data_in;
                end_ptr <= (end_ptr + 1) % size;
                is_empty <= is_empty ? 0 : is_empty; // Could also be is_empty <= 0;
            end else begin
                data_out <= 'hDEAD; // Buffer at_capacity
            end
        end else if (pop_buffer && !push_buffer && !read_buffer) begin
            if (!is_empty) begin
                beginning_ptr <= (beginning_ptr + 1) % size;
                data_out <= buffer[beginning_ptr];
                buffer[beginning_ptr] <= '0; // Clear the popped data. NOT NECESSARY
                is_empty <= (((beginning_ptr + 1) % size) == end_ptr);
            end else begin
                data_out <= 'hDEAD; // No data to pop
            end
        end else if (read_buffer && !push_buffer && !pop_buffer) begin
            if (!is_full && !is_empty) begin
                data_out <= buffer[beginning_ptr];
            end else begin
                data_out <= 'hDEAD; // No data to read
            end
        end
    end

endmodule
