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


    wire [(`WORD - 1):0] pcnext, pcnextbr, pcplus4, pcbranch, jmp_base, jmp_pc, jmp_fin_pc;
    wire [(`WORD - 1):0] imm;
    wire [4:0] ra1;
    wire [(`WORD - 1):0] rd1;
    wire [(`WORD - 1):0] srca, srcb;
    wire [(`WORD - 1):0] result;

    wire branch, inv_br;       

    decoder dec (.instr(instr), .memtoreg(memtoreg), .memwrite(memwrite),
                .branch(branch), .alusrcA(alusrcA), .alusrcB(alusrcB),
                .alusrc_a_zero(alusrc_a_zero), .imm(imm),
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

    assign jmp_pc = (jmp_base + imm) & 32'hFFFFFFFE;

    assign pcnext =  jump ? jmp_pc: pcnextbr;

    regfile rf(.clk(clk), .rn1(instr[19:15]),
               .rn2(instr[24:20]),
               .we(regwrite), .wn(instr[11:7]),
               .wd(result), .rd1(rd1), .rd2(writedata)); 

    assign result = memtoreg ? readdata : aluout;

    assign srca = alusrcA[0] ? pc : rd1;

    assign srcb = (alusrcB == 0) ? writedata : (alusrcB == 1) ? imm : 32'd4;

    alu alu(.src1(srca), .src2(srcb),
            .alu_op(alucontrol), .result(aluout),
            .zero(zero));
    
endmodule
