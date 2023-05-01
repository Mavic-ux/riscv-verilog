`include "aluop.v"

module alu(
    input [(`WORD - 1):0] a, b,
    input [3:0] aluctr,
    output reg [(`WORD - 1):0] aluout,
    output reg iszero
);
    logic [4:0] shamt = b[4:0];
    always_latch 
        begin
            case (aluctr)
                `ALU_ADD:
                    aluout = a + b;
                `ALU_SUB:
                    aluout = a - b;
                `ALU_AND:
                    aluout = a & b;
                `ALU_OR:
                    aluout = a | b;
                `ALU_XOR:
                    aluout = a ^ b;
                `ALU_SLTU:
                    aluout = {{(`WORD - 1){1'b0}}, a < b};
                `ALU_SLT:
                    aluout = {{(`WORD - 1){1'b0}}, $signed(a) < $signed(b)};
                `ALU_SLL:
                    aluout = a << shamt;
                `ALU_SRL:
                    aluout = a >> shamt;
                `ALU_SRA:
                    aluout = $signed(a) >>> shamt;
                default:
                    ;
            endcase
            iszero = (aluout == 0);
        end
endmodule
