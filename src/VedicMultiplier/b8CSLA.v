module b8CSLA (
    input [7:0] A,
    input [7:0] B,
    //input Cin,
    output [7:0] S,
    output Cout
);
    wire [1:0] S10, S20, S21, S30, S31, S40, S41;
    //wire [1:0] S11; Cin=0 always
    wire C10, C20, C21, C30, C31, C40, C41;
    //wire C11; Cin = 0 always
    wire CP1, CP2, CP3;
    b2RCA RCA10 (.A(A[1:0]), .B(B[1:0]), .Cin(1'b0), .S(S10), .Cout(C10));
    //b2RCA RCA11 (.A(A[1:0]), .B(B[1:0]), .Cin(1'b1), .S(S11), .Cout(C11));

    b2RCA RCA20 (.A(A[3:2]), .B(B[3:2]), .Cin(1'b0), .S(S20), .Cout(C20));
    b2RCA RCA21 (.A(A[3:2]), .B(B[3:2]), .Cin(1'b1), .S(S21), .Cout(C21));

    b2RCA RCA30 (.A(A[5:4]), .B(B[5:4]), .Cin(1'b0), .S(S30), .Cout(C30));
    b2RCA RCA31 (.A(A[5:4]), .B(B[5:4]), .Cin(1'b1), .S(S31), .Cout(C31));

    b2RCA RCA40 (.A(A[7:6]), .B(B[7:6]), .Cin(1'b0), .S(S40), .Cout(C40));
    b2RCA RCA41 (.A(A[7:6]), .B(B[7:6]), .Cin(1'b1), .S(S41), .Cout(C41));

   //assign S[1:0] = Cin ? S11 : S10;
   //assign CP = Cin ? C11 : C10;

   //We don't need the part for Cin=1 because in our use case it never occurs.

   assign S[1:0] = S10;
   assign CP1 = C10;

   assign S[3:2] = CP1 ? S21 : S20;
   assign CP2 = CP1 ? C21 : C20;

   assign S[5:4] = CP2 ? S31 : S30;
   assign CP3 = CP2 ? C31 : C30;

   assign S[7:6] = CP3 ? S41 : S40;
   assign Cout = CP3 ? C41 : C40;
endmodule