`include "../src/headers.v"
module tb_b4CSLA();

    reg [8:0] inps;
    wire [3:0] S;
    wire Cout;
    integer i;
    b4CSLA DFT (.A(inps[8:5]), .B(inps[4:1]), .Cin(inps[0]), .S(S), .Cout(Cout));
    initial begin
        inps=9'b000000000;
        for(i=0;i<512;i++) begin
            #1
            $display("A: %b  B= %b Cin=%b  S= %b, Cout=%b", inps[8:5], inps[4:1], inps[0], S, Cout);
            inps=inps+1;
        end
    end

endmodule