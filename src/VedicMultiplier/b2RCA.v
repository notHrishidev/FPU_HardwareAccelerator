module b2RCA (
    input [1:0] A,
    input [1:0] B,
    input Cin,
    output [1:0] S,
    output Cout
);
    wire CP;
    assign CP = (A[0] & B[0]) | (A[0] & Cin) | (B[0] & Cin);
    assign S[0] = A[0] ^ B[0] ^ Cin;
    assign S[1] = A[1] ^ B[1] ^ CP;
    assign Cout = (A[1] & B[1]) | (A[1] & CP) | (B[1] & CP);
endmodule