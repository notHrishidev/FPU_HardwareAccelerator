`include "headers.v"
module tb_Vedic_2x2();

    reg [1:0] A,B;
    wire [3:0] out;
    integer i,j;
    Vedic_2x2 DFT (.A(A), .B(B), .out(out));

    initial begin
        A=2'b00;
        B=2'b00;
        for(i=0;i<4;i++) begin
            for(j=0;j<4;j++) begin
                #1
                $display("A: %d  B= %b  out= %d", A, B, out);
                B=B+1;
            end
            A=A+1;
        end
    end

endmodule