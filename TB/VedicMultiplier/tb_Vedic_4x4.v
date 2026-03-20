`include "../src/headers.v"
module tb_Vedic_4x4();

    reg [3:0] A,B;
    wire [7:0] out;
    integer i,j;
    Vedic_4x4 DFT (.A(A), .B(B), .out(out));

    initial begin
        A=4'b0000;
        B=4'b0000;
        for(i=0;i<16;i++) begin
            for(j=0;j<16;j++) begin
                #1
                $display("A: %d  B= %d  out= %d", A, B, out);
                B=B+1;
            end
            A=A+1;
        end
    end

endmodule