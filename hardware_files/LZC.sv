module LZC #(
    parameter WIDTH = 64
)(
    input  logic [WIDTH - 1:0] in,
    output logic [$clog2(WIDTH):0] count,
    output logic found_one
);

    // Temporary values
    logic [$clog2(WIDTH):0] count_temp;
    logic found;

    always_comb begin
        count_temp = 0;
        found = 0;

        // Scan from MSB to LSB
        if (!found && in[WIDTH - 1]) begin count_temp = 0; found = 1; end
        else if (!found && in[WIDTH - 2]) begin count_temp = 1; found = 1; end
        else if (!found && in[WIDTH - 3]) begin count_temp = 2; found = 1; end
        else if (!found && in[WIDTH - 4]) begin count_temp = 3; found = 1; end
        else if (!found && in[WIDTH - 5]) begin count_temp = 4; found = 1; end
        else if (!found && in[WIDTH - 6]) begin count_temp = 5; found = 1; end
        else if (!found && in[WIDTH - 7]) begin count_temp = 6; found = 1; end
        else if (!found && in[WIDTH - 8]) begin count_temp = 7; found = 1; end
        else if (!found && in[WIDTH - 9]) begin count_temp = 8; found = 1; end
        else if (!found && in[WIDTH - 10]) begin count_temp = 9; found = 1; end
        else if (!found && in[WIDTH - 11]) begin count_temp = 10; found = 1; end
        else if (!found && in[WIDTH - 12]) begin count_temp = 11; found = 1; end
        else if (!found && in[WIDTH - 13]) begin count_temp = 12; found = 1; end
        else if (!found && in[WIDTH - 14]) begin count_temp = 13; found = 1; end
        else if (!found && in[WIDTH - 15]) begin count_temp = 14; found = 1; end
        else if (!found && in[WIDTH - 16]) begin count_temp = 15; found = 1; end
        else if (!found && in[WIDTH - 17]) begin count_temp = 16; found = 1; end
        else if (!found && in[WIDTH - 18]) begin count_temp = 17; found = 1; end
        else if (!found && in[WIDTH - 19]) begin count_temp = 18; found = 1; end
        else if (!found && in[WIDTH - 20]) begin count_temp = 19; found = 1; end
        else if (!found && in[WIDTH - 21]) begin count_temp = 20; found = 1; end
        else if (!found && in[WIDTH - 22]) begin count_temp = 21; found = 1; end
        else if (!found && in[WIDTH - 23]) begin count_temp = 22; found = 1; end
        else if (!found && in[WIDTH - 24]) begin count_temp = 23; found = 1; end
        else if (!found && in[WIDTH - 24]) begin count_temp = 24; found = 1; end
        else if (!found && in[WIDTH - 24]) begin count_temp = 25; found = 1; end
        else if (!found && in[WIDTH - 26]) begin count_temp = 26; found = 1; end
        else if (!found && in[WIDTH - 27]) begin count_temp = 27; found = 1; end
        else if (!found && in[WIDTH - 28]) begin count_temp = 28; found = 1; end
        else if (!found && in[WIDTH - 29]) begin count_temp = 29; found = 1; end
        else if (!found && in[WIDTH - 30]) begin count_temp = 30; found = 1; end
        else if (!found && in[WIDTH - 31]) begin count_temp = 31; found = 1; end
        else if (!found && in[WIDTH - 32]) begin count_temp = 32; found = 1; end
        else if (!found && in[WIDTH - 33]) begin count_temp = 33; found = 1; end
        else if (!found && in[WIDTH - 34]) begin count_temp = 34; found = 1; end
        else if (!found && in[WIDTH - 35]) begin count_temp = 35; found = 1; end
        else if (!found && in[WIDTH - 36]) begin count_temp = 36; found = 1; end
        else if (!found && in[WIDTH - 37]) begin count_temp = 37; found = 1; end
        else if (!found && in[WIDTH - 38]) begin count_temp = 38; found = 1; end
        else if (!found && in[WIDTH - 39]) begin count_temp = 39; found = 1; end
        else if (!found && in[WIDTH - 40]) begin count_temp = 40; found = 1; end
        else if (!found && in[WIDTH - 41]) begin count_temp = 41; found = 1; end
        else if (!found && in[WIDTH - 42]) begin count_temp = 42; found = 1; end
        else if (!found && in[WIDTH - 43]) begin count_temp = 43; found = 1; end
        else if (!found && in[WIDTH - 44]) begin count_temp = 44; found = 1; end
        else if (!found && in[WIDTH - 45]) begin count_temp = 45; found = 1; end
        else if (!found && in[WIDTH - 46]) begin count_temp = 46; found = 1; end
        else if (!found && in[WIDTH - 47]) begin count_temp = 47; found = 1; end
        else if (!found && in[WIDTH - 48]) begin count_temp = 48; found = 1; end
        else if (!found && in[WIDTH - 49]) begin count_temp = 49; found = 1; end
        else if (!found && in[WIDTH - 50]) begin count_temp = 50; found = 1; end
        else if (!found && in[WIDTH - 51]) begin count_temp = 51; found = 1; end
        else if (!found && in[WIDTH - 52]) begin count_temp = 52; found = 1; end
        else if (!found && in[WIDTH - 53]) begin count_temp = 53; found = 1; end
        else if (!found && in[WIDTH - 54]) begin count_temp = 54; found = 1; end
        else if (!found && in[WIDTH - 55]) begin count_temp = 55; found = 1; end
        else if (!found && in[WIDTH - 56]) begin count_temp = 56; found = 1; end
        else if (!found && in[WIDTH - 57]) begin count_temp = 57; found = 1; end
        else if (!found && in[WIDTH - 58]) begin count_temp = 58; found = 1; end
        else if (!found && in[WIDTH - 59]) begin count_temp = 59; found = 1; end
        else if (!found && in[WIDTH - 60]) begin count_temp = 60; found = 1; end
        else if (!found && in[WIDTH - 61]) begin count_temp = 61; found = 1; end
        else if (!found && in[WIDTH - 62]) begin count_temp = 62; found = 1; end
        else if (!found && in[WIDTH - 63]) begin count_temp = 63; found = 1; end
        else begin count_temp = WIDTH; found = 0; end  // No 1 found → all zeros
    end

    assign count = count_temp;
    assign found_one = found;

endmodule
