`include "../src/headers.v"
module tb_b2RCA();

    reg [4:0] inps;
    wire [1:0] S;
    wire Cout;
    integer i;
    b2RCA DFT (.A(inps[4:3]), .B(inps[2:1]), .Cin(inps[0]), .S(S), .Cout(Cout));
    initial begin
        inps=5'b00000;
        for(i=0;i<32;i++) begin
            #1
            $display("A: %b  B= %b Cin=%b  S= %b, Cout=%b", inps[4:3], inps[2:1], inps[0], S, Cout);
            inps=inps+1;
        end
    end

endmodule