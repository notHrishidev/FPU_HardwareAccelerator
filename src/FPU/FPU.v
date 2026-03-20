module FPU (
    input [15:0] A,
    input [15:0] B,
    input clk,
    input reset,
    input burst,
    input enable,
    output reg [15:0] P,
    output reg ovf,
    output reg ready
);
    wire [15:0] mulOut16;
    wire [7:0] addOut;
    wire ovf_out;
    reg [7:0] mulA_reg, mulB_reg, addA_reg, addB_reg;
    reg [6:0] mulOut;
    reg burst_reg;

    parameter Idle = 2'b00;
    parameter Calc = 2'b01;
    parameter FPUAdj = 2'b10;
    parameter ResOut = 2'b11;

    reg [1:0] nxtSt;

    //Instantiating modules:
    Vedic_8x8 vMul(.A(mulA_reg), .B(mulB_reg), .out(mulOut16));
    SQRT_CSLA sqrtAdd(.A(addA_reg), .B(addB_reg), .S(addOut), .ovf(ovf_out));
    
    //RESET LOGIC:
    always @(*) begin
        if (reset) begin
            mulA_reg  = 0;
            mulB_reg  = 0;
            addA_reg  = 0;
            addB_reg  = 0;
            ovf       = 0;
            ready     = 1;
            nxtSt     = Idle;
        end
    end

    //State transition logic:
    always @(posedge clk) begin
        if (enable & ~reset) begin
            case (nxtSt)
                Idle    : nxtSt <= enable ? Calc : Idle;
                Calc    : nxtSt <= FPUAdj;
                FPUAdj  : nxtSt <= ResOut;
                ResOut  : nxtSt <= burst_reg ? Calc : Idle;
                default : nxtSt <= Idle; 
            endcase
        end
    end

    //FSM States definitions:
    always @(posedge clk) begin
        if (enable & ~reset) begin
            //currSt <= nxtSt;
            case (nxtSt)
                Idle:
                    begin
                        mulA_reg  <= 0;
                        mulB_reg  <= 0;
                        addA_reg  <= 0;
                        addB_reg  <= 0;
                        ready     <= 1;
                    end
                Calc:
                    begin
                        ready    <= 0;
                        burst_reg<= burst;
                        mulA_reg <= {1'b1, A[6:0]};
                        mulB_reg <= {1'b1, B[6:0]};
                        addA_reg <= A[14:7];
                        addB_reg <= B[14:7];
                    end
                FPUAdj:
                    begin
                        addA_reg    <= addOut;
                        addB_reg    <= mulOut16[15] ? 8'd1 : 8'd0;
                        mulOut <= mulOut16[15] ? mulOut16[14:8] : mulOut16[13:7];
                    end
                ResOut:
                    begin
                        ready   <= 1;
                        P[15]   <= (A[15] ^ B[15]);
                        P[6:0]  <= mulOut;
                        P[14:7] <= addOut;
                    end
            endcase
        end
    end


    //Overflow logic (Sticky flag, gets set once ovf_out ever becomes 1)
    always @(posedge clk) begin
        if (ovf_out) begin
            ovf <= 1;
        end
    end
endmodule