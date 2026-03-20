module b4CSLA (
    input [3:0] A,
    input [3:0] B,
    //input Cin,
    output [3:0] S,
    output Cout
);
    wire [1:0] S10, S20, S21;
    //wire [1:0] S11; Cin=0 always
    wire C10, C20, C21;
    //wire C11; Cin = 0 always
    wire CP;
    b2RCA RCA10 (.A(A[1:0]), .B(B[1:0]), .Cin(1'b0), .S(S10), .Cout(C10));
    //b2RCA RCA11 (.A(A[1:0]), .B(B[1:0]), .Cin(1'b1), .S(S11), .Cout(C11));

    b2RCA RCA20 (.A(A[3:2]), .B(B[3:2]), .Cin(1'b0), .S(S20), .Cout(C20));
    b2RCA RCA21 (.A(A[3:2]), .B(B[3:2]), .Cin(1'b1), .S(S21), .Cout(C21));

   //assign S[1:0] = Cin ? S11 : S10;
   //assign CP = Cin ? C11 : C10;

   //We don't need the part for Cin=1 because in our use case it never occurs.

   assign S[1:0] = S10;
   assign CP = C10;

   assign S[3:2] = CP ? S21 : S20;
   assign Cout = CP ? C21 : C20;
endmodule