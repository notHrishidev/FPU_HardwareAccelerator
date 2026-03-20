`include "../../src/headers.v"
module tb_Vedic_8x8();

    reg [7:0] A,B;
    reg [15:0] prod;
    wire [15:0] out;
    integer i,j;
    Vedic_8x8 DFT (.A(A), .B(B), .out(out));

    initial begin
        A=8'b11000000;
        B=8'b11000000;
        #1
        prod=out;
        $display("A: %d  B= %d  out= %b", A, B, out);
    end

endmodule