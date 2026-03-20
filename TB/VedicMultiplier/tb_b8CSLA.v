`include "../src/headers.v"
module tb_b8CSLA();

    reg [7:0] A,B;
    wire [7:0] S;
    wire Cout;
    b8CSLA DFT (.A(A), .B(B), .S(S), .Cout(Cout));
    initial begin
        A=8'd100;
        B=8'd100;
        #10
        $display("A: %d  B= %d  S= %d, Cout=%b", A, B, S, Cout);
    end

endmodule