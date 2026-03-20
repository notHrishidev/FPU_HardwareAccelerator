module SQRT_CSLA 
#(
    parameter N1=1, N2=3, N3=4
)
(
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,
    output ovf
    );
    wire [N1-1:0] S10, S11;
    wire [N2-1:0] S20, S21;
    wire [N3-1:0] S30, S31;

    wire C10, C11, C20, C21, C30, C31;
    wire CP12, CP23;
    wire Cout;

    bNRCA #(.N(N1)) b10 (.A(A[N1-1:0]), .B(B[N1-1:0]), .Cin(1'b0), .S(S10), .Cout(C10));
    //bNRCA #(N=2) b11 (.A(A[1:0]), .B(B[1:0]), .Cin(1'b1), .S(S11), .Cout(C11));
    //Carry in is assumed to be zero.
    
    bNRCA #(.N(N2)) b20 (.A(A[N1+N2-1:N1]), .B(B[N1+N2-1:N1]), .Cin(1'b0), .S(S20), .Cout(C20));
    bNRCA #(.N(N2)) b21 (.A(A[N1+N2-1:N1]), .B(B[N1+N2-1:N1]), .Cin(1'b1), .S(S21), .Cout(C21));

    bNRCA #(.N(N3)) b30 (.A(A[N1+N2+N3-1:N1+N2]), .B(B[N1+N2+N3-1:N1+N2]), .Cin(1'b0), .S(S30), .Cout(C30));
    bNRCA #(.N(N3)) b31 (.A(A[N1+N2+N3-1:N1+N2]), .B(B[N1+N2+N3-1:N1+N2]), .Cin(1'b1), .S(S31), .Cout(C31));

    //assign S[1:0] = Cin? S11 : S10;
    assign S[N1-1:0] = S10;
    assign S[N1+N2-1:N1] = CP12 ? S21 : S20;
    assign S[N1+N2+N3-1:N1+N2] = CP23 ? S31 : S30;

    //assign CP12 = Cin? C11 : C10;
    //Carry in is assumed to be zero
    assign CP12 = C10;
    assign CP23 = CP12 ? C21 : C20;
    assign Cout = CP23 ? C31 : C30;
    assign ovf = ~(A[7] ^ B[7]) & (A[7] ^ S[7]);
endmodule