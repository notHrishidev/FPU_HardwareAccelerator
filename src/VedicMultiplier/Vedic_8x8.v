module Vedic_8x8 (
    input [7:0] A,
    input [7:0] B,
    output [15:0] out
);
    wire [7:0] pLL, pLH, pHL, pHH;
    Vedic_4x4 mLL (.A(A[3:0]), .B(B[3:0]), .out(pLL));
    Vedic_4x4 mLH (.A(A[3:0]), .B(B[7:4]), .out(pLH));
    Vedic_4x4 mHL (.A(A[7:4]), .B(B[3:0]), .out(pHL));
    Vedic_4x4 mHH (.A(A[7:4]), .B(B[7:4]), .out(pHH));

    wire [7:0] S_0, S_1;
    wire [3:0] S_2;
    wire Cout_0, Cout_1, Cout_2;
    b8CSLA b8Adder_0 (.A(pLH), .B(pHL), .S(S_0), .Cout(Cout_0));
    
    b8CSLA b8Adder_1 (.A({pHH[3:0],pLL[7:4]}), .B(S_0), .S(S_1), .Cout(Cout_1));
    
    wire HAsum, HAcout;
    assign HAsum = Cout_0 ^ Cout_1;
    assign HAcout = Cout_0 & Cout_1;

    b4CSLA b4Adder_0 (.A({2'b00,HAcout,HAsum}), .B(pHH[7:4]), .S(S_2), .Cout(Cout_2));

    assign out = {S_2,S_1,pLL[3:0]};
endmodule