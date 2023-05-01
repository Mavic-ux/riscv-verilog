`include "datapath.v"


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

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];


    logic branch, inv_br;
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


                 
    datapath dp(.clk(clk), .reset(reset),
                .hlt(hlt), .memtoreg(memtoreg),
                .pcsrc(pcsrc), .jumpsrc(jumpsrc),
                .alusrcA(alusrcA), .alusrcB(alusrcB), .regwrite(regwrite),
                .jump(jump), .alucontrol(alucontrol),
                .alusrc_a_zero(alusrc_a_zero), .zero(zero),
                .pc(pc), .instr(instr),
                .aluout(aluout), .writedata(writedata),
                .readdata(readdata));
endmodule
