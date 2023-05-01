`include "consts.v"

module datapath (
        input clk, reset, hlt,
        input memtoreg, pcsrc, jumpsrc,
        input [1:0] alusrcA, alusrcB,
        input regwrite, jump,
        input [3:0] alucontrol,
        input alusrc_a_zero,
        output zero,
        output [31:0] pc,
        input [31:0] instr,
        output [31:0] aluout, writedata,
        input [31:0] readdata
);
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch, jmp_base, jmp_pc, jmp_fin_pc;
    logic [31:0] imm;
    logic [4:0] ra1;
    logic [31:0] rd1;
    logic [31:0] srca, srcb;
    logic [31:0] result;


    always @(posedge clk)
        if (hlt)
            $finish;

    flopr #(32) pcreg(.clk(clk), .reset(reset), .d(pcnext), .q(pc));
    adder pcadd1(.a(pc), .b(32'd4), .y(pcplus4));
    adder pcadd2(.a(pc), .b(imm), .y(pcbranch));

    assign pcnextbr = pcsrc ? pcbranch : pcplus4;

    assign jmp_base = jumpsrc ? rd1 : pc;

    adder jmptar(.a(jmp_base), .b(imm), .y(jmp_pc));
    assign jmp_fin_pc = jmp_pc & ~1;

    mux2 #(32) pcmux(.d0(pcnextbr), .d1(jmp_fin_pc), .s(jump), .y(pcnext));

    immSel immsel(.instr(instr), .imm(imm));
    assign ra1 = instr[19:15] & ~{5{alusrc_a_zero}};
    regfile rf(.clk(clk), .ra1(ra1),
               .ra2(instr[24:20]),
               .we3(regwrite), .wa3(instr[11:7]),
               .wd3(result),
               .rd1(rd1), .rd2(writedata)); 


    mux2 #(32) resmux(.d0(aluout), .d1(readdata),
                      .s(memtoreg), .y(result));

    mux2 #(32) srcamux(.d0(rd1), .d1(pc),
                       .s(alusrcA[0]), .y(srca));


    mux3 #(32) srcbmux(.d0(writedata), .d1(imm),
                       .d2(32'd4),
                       .s(alusrcB), .y(srcb));
                

    alu alu(.a(srca), .b(srcb),
            .aluctr(alucontrol), .aluout(aluout),
            .iszero(zero));

endmodule
