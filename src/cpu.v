module cpu (
    input wire clk, reset,
    output wire[(`WORD - 1):0] pc,
    input wire [(`WORD - 1):0] instr,
    output wire memwrite,
    output wire[(`WORD - 1):0] aluout, writedata,
    input wire[(`WORD - 1):0] readdata
);
    wire memtoreg, regwrite, jump;
    wire[1:0] alusrcA, alusrcB;
    wire pcsrc, zero, alusrc_a_zero;
    wire jumpsrc, hlt;
    wire[3:0] alucontrol;

    wire [6:0] op, funct7;
    wire [2:0] funct3;

    wire [(`WORD - 1):0] pcnext, pcnextbr, pcplus4, pcbranch, jmp_base, jmp_pc, jmp_fin_pc;
    wire [(`WORD - 1):0] imm;
    wire [4:0] ra1;
    wire [(`WORD - 1):0] rd1;
    wire [(`WORD - 1):0] srca, srcb;
    wire [(`WORD - 1):0] result;

    assign op = instr[6:0];
    assign funct7 = instr[(`WORD - 1):25];
    assign funct3 = instr[14:12];

    wire branch, inv_br;       

    decoder dec (.opcode(op), .funct3(funct3), .funct7(funct7),
                .memtoreg(memtoreg), .memwrite(memwrite),
                .branch(branch), .alusrcA(alusrcA), .alusrcB(alusrcB),
                .alusrc_a_zero(alusrc_a_zero),
                .alucontrol(alucontrol), .inv_br(inv_br),
                .regwrite(regwrite), .jump(jump),
                .jumpsrc(jumpsrc), .hlt(hlt));

    assign pcsrc = branch & (zero ^ inv_br);

    always @(posedge clk) begin
        if (hlt)
            $finish;
        else
        $display("PC = %0d", pc);
    end

    flopr #(32) pcreg(.clk(clk), .reset(reset), .d(pcnext), .q(pc));

    assign pcplus4 = pc + 32'd4;

    assign pcbranch = pc + imm;

    assign pcnextbr = pcsrc ? pcbranch : pcplus4;

    assign jmp_base = jumpsrc ? rd1 : pc;

    assign jmp_pc = jmp_base + imm;

    assign jmp_fin_pc = jmp_pc & ~1;

    assign pcnext =  jump ? jmp_fin_pc : pcnextbr;

    immSel immsel(.instr(instr), .imm(imm));

    assign ra1 = instr[19:15] & ~{5{alusrc_a_zero}};
    regfile rf(.clk(clk), .ra1(ra1),
               .ra2(instr[24:20]),
               .we3(regwrite), .wa3(instr[11:7]),
               .wd3(result),
               .rd1(rd1), .rd2(writedata)); 

    assign result = memtoreg ? readdata : aluout;

    assign srca = alusrcA[0] ? pc : rd1;

    assign srcb = (alusrcB == 0) ? writedata : (alusrcB == 1) ? imm : 32'd4;

    alu alu(.a(srca), .b(srcb),
            .aluctr(alucontrol), .aluout(aluout),
            .iszero(zero));
    
endmodule
