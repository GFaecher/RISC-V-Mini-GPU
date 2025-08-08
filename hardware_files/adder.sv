module adder (x, y, carry, out, cout);
    input x;
    input y;
    input carry;

    output out;
    output cout;


    assign out = x ^ y ^ carry;
    assign cout = (x & y) | (carry & x) | (carry & y);   

endmodule