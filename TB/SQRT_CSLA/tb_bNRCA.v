`include "../../src/headers.v"
module tb_bNRCA();

    parameter N=1;
    reg [N-1:0] A;
    reg [N-1:0] B;
    reg Cin;
    wire [N-1:0] S;
    wire Cout;
    bNRCA #(.N(N)) DFT (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
    initial begin
        A='d1;
        B='d1;
        Cin = 0;
        #1
        $display("A=%d  B=%d  Cin=%d, S=%d Cout=%d", A, B, Cin, S, Cout);
    end

endmodule