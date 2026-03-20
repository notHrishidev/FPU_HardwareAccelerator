module Vedic_4x4 (
    input [3:0] A,
    input [3:0] B,
    output [7:0] out
);
    wire [3:0] pLL, pLH, pHL, pHH;
    Vedic_2x2 mLL (.A(A[1:0]), .B(B[1:0]), .out(pLL));
    Vedic_2x2 mLH (.A(A[1:0]), .B(B[3:2]), .out(pLH));
    Vedic_2x2 mHL (.A(A[3:2]), .B(B[1:0]), .out(pHL));
    Vedic_2x2 mHH (.A(A[3:2]), .B(B[3:2]), .out(pHH));

    wire [3:0] S_0, S_1, S_2;
    wire Cout_0, Cout_1, Cout_2;
    b4CSLA b4Adder_0 (.A(pLH), .B(pHL), .S(S_0), .Cout(Cout_0));
    
    b4CSLA b4Adder_1 (.A({2'b00,pLL[3:2]}), .B(S_0), .S(S_1), .Cout(Cout_1));
    
    wire HAsum, HAcout;
    assign HAsum = Cout_0 ^ Cout_1;
    assign HAcout = Cout_0 & Cout_1;

    b4CSLA b4Adder_2 (.A({HAcout,HAsum,S_1[3:2]}), .B(pHH), .S(S_2), .Cout(Cout_2));

    assign out = {S_2,S_1[1:0], pLL[1:0]};
endmodule