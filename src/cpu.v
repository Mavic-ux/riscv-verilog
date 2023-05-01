module cpu (
    input wire clk, reset,
    output wire[31:0] pc,
    input wire [31:0] instr,
    output wire memwrite, output wire [2:0] memsize,
    output wire[31:0] aluout, writedata,
    input wire[31:0] readdata
);
    wire memtoreg, regwrite, jump;
    wire[1:0] alusrcA, alusrcB;
    wire pcsrc, zero, alusrc_a_zero;
    wire jumpsrc, hlt;
    wire[3:0] alucontrol;

    wire [6:0] op, funct7;
    wire [2:0] funct3;

    wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch, jmp_base, jmp_pc, jmp_fin_pc;
    wire [31:0] imm;
    wire [4:0] ra1;
    wire [31:0] rd1;
    wire [31:0] srca, srcb;
    wire [31:0] result;

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];

    wire branch, inv_br;
    maindec md (.op(op), .funct3(funct3),
                .memtoreg(memtoreg), .memwrite(memwrite),
                .memsize(memsize), .branch(branch),
                .alusrcA(alusrcA), .alusrcB(alusrcB),
                .alusrc_a_zero(alusrc_a_zero),
                .regwrite(regwrite), .jump(jump),
                .jumpsrc(jumpsrc), .hlt(hlt));
    aludec ad (.opcode(op), .funct3(funct3),
               .funct7(funct7), .alucontrol(alucontrol),
               .inv_br(inv_br));
    assign pcsrc = branch & (zero ^ inv_br);


    always @(posedge clk) begin
        if (hlt)
            $finish;
        else
        $display("PC = %0d", pc);
    end

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
