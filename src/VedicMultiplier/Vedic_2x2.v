module Vedic_2x2 (
    input [1:0] A,
    input [1:0] B,
    output [3:0] out
);
    wire pHH,pHL,pLH;
    assign pLH = A[0] & B[1];
    assign pHL = A[1] & B[0];
    assign pHH = A[1] & B[1];
    assign out[0] = A[0] & B[0];
    assign out[1] = pHL ^ pLH;
    assign out[2] = pHH ^ (pHL & pLH);
    assign out[3] = pHH & (pHL & pLH);
endmodule