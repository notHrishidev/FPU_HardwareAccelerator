module bNRCA 
#(
    parameter N = 4
)
(
    input [N-1:0] A,
    input [N-1:0] B,
    input Cin,
    output [N-1:0] S,
    output Cout
);
    wire [N:0] CP;
    genvar i;
    generate
        for (i = 0; i<N; i=i+1) begin
            FA u0(.A(A[i]), .B(B[i]), .Cin(CP[i]), .S(S[i]), .Cout(CP[i+1]));
        end
    endgenerate
    assign CP[0] = Cin;
    assign Cout = CP[N];
endmodule