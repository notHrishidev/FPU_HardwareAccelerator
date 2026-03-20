`include "../../src/headers.v"
module tb_SQRT_CSLA ();
    
    reg signed [7:0] A;
    reg signed [7:0] B;
    reg signed [7:0] Sum;
    wire signed [7:0] S;
    wire ovf;


    SQRT_CSLA #(.N1(1), .N2(3), .N3(4)) DFT (.A(A), .B(B), .S(S), .ovf(ovf));
    initial begin
        A=15;
        B=120;
        #1;
        Sum=S;
        $display("A=%b-%b --> %d,\nB=%b-%b --> %d,\nS=%b-%b --> %d,\nC=%b, ovf=%b",A[7], A[6:0], A, B[7], B[6:0], B, S[7], S[6:0], Sum, DFT.Cout, ovf);
    end
endmodule