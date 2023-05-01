`include "aluop.v"

module decoder(
    input wire [(`WORD - 1):0] instr,
    output logic memtoreg, memwrite,
    output logic branch,
    output logic[1:0] alusrcA,
    output logic[1:0] alusrcB,
    output logic alusrc_a_zero,
    output logic regwrite,
    output logic jump,
    output logic jumpsrc,
    output logic hlt,
    output [(`WORD - 1):0] imm,
    output reg [3:0] alucontrol,
    output inv_br
);
    wire [6:0] opcode, funct7;
    wire [2:0] funct3;

    assign opcode = instr[6:0];
    assign funct7 = instr[(`WORD - 1):25];
    assign funct3 = instr[14:12];
  
    always_comb
    case(opcode)
        `OPC_LUI: begin
            imm = {instr[31:12], 12'b0}; // U type
            alusrc_a_zero = (opcode == `OPC_LUI);
            alusrcA = `ALU_SRCA_REG;
            alusrcB = `ALU_SRCB_IMM;
            alucontrol = `ALU_ADD;
            regwrite = 1;
            memtoreg = 0;
            memwrite = 0;
            branch = 0;
            jump = 0;
            jumpsrc = 0;
            hlt = 0;
        end
        `OPC_I_TYPE: begin
            imm = {{20{instr[31]}}, instr[31:20]}; // I type
            alusrc_a_zero = (opcode == `OPC_LUI);
            alusrcA = `ALU_SRCA_REG;
            alusrcB = `ALU_SRCB_IMM;
            regwrite = 1;
            memtoreg = 0;
            memwrite = 0;
            branch = 0;
            jump = 0;
            jumpsrc = 0;
            hlt = 0;
            case(funct3)
            `ALU_INSTR_ADDI: begin
                alucontrol = `ALU_ADD;
            end
            default: begin assert(0); end
            endcase;
        end
        `OPC_R_TYPE: begin
            imm = {{20{instr[31]}}, instr[31:20]}; // I type 
            alusrcA = `ALU_SRCA_REG;
            alusrcB = `ALU_SRCB_REG;
            regwrite = (opcode == `OPC_R_TYPE);
            memtoreg = 0;
            memwrite = 0;
            branch = (opcode == `OPC_BRANCH);
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
            hlt = 0;
            case(funct3)
            `ALU_INSTR_ADD: begin
                alucontrol = `ALU_ADD;
            end
            default: begin assert(0); end
            endcase;
        end
        `OPC_BRANCH: begin
            imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B type
            alusrcA = `ALU_SRCA_REG;
            alusrcB = `ALU_SRCB_REG;
            regwrite = (opcode == `OPC_R_TYPE);
            memtoreg = 0;
            memwrite = 0;
            branch = (opcode == `OPC_BRANCH);
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
            hlt = 0;
            case(funct3)
            `ALU_INSTR_BLT: begin
                alucontrol = `ALU_SLT;
            end
            default: begin assert(0); end
            endcase;
        end
        `OPC_JAL: begin
            imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J type
            jumpsrc = (opcode == `OPC_JALR);
            alusrcA = `ALU_SRCA_PC;
            alusrcB = `ALU_SRCB_FOUR;
            alucontrol = `ALU_ADD;
            alusrc_a_zero = 0;
            jump = 1;
            regwrite = 1;
            memtoreg = 0;
            memwrite = 0;
            branch = 0;
            hlt = 0;
        end
        `OPC_JALR: begin
            imm = {{20{instr[31]}}, instr[31:20]}; // U type
            jumpsrc = (opcode == `OPC_JALR);
            alusrcA = `ALU_SRCA_PC;
            alusrcB = `ALU_SRCB_FOUR;
            alucontrol = `ALU_ADD;
            alusrc_a_zero = 0;
            jump = 1;
            regwrite = 1;
            memtoreg = 0;
            memwrite = 0;
            branch = 0;
            hlt = 0;
        end
        `OPC_LOAD: begin
            imm = {{20{instr[31]}}, instr[31:20]}; // U type
            alusrcA = `ALU_SRCA_REG;
            alusrcB = `ALU_SRCB_IMM;
            alucontrol = `ALU_ADD;
            regwrite = (opcode == `OPC_LOAD);
            memtoreg = (opcode == `OPC_LOAD);
            memwrite = (opcode == `OPC_STORE);
            branch = 0;
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
            hlt = 0;
        end
        `OPC_STORE: begin
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S type
            alusrcA = `ALU_SRCA_REG;
            alusrcB = `ALU_SRCB_IMM;
            alucontrol = `ALU_ADD;
            regwrite = (opcode == `OPC_LOAD);
            memtoreg = (opcode == `OPC_LOAD);
            memwrite = (opcode == `OPC_STORE);
            branch = 0;
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
            hlt = 0;
        end
        `OPC_SYSTEM: begin
            imm = instr;
            hlt = 1;
            alusrcA = 2'bxx;
            alusrcB = 2'bxx;
            alucontrol = `ALU_ADD;
            memwrite = 0;
            memtoreg = 0;
            branch = 0;
            regwrite = 0;
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
        end
        `ZERO: begin
            imm = instr;
            alusrcA = 2'bxx;
            alusrcB = 2'bxx;
            alucontrol = 4'bxxxx;
            memwrite = 0;
            memtoreg = 0;
            branch = 0;
            regwrite = 0;
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
            hlt = 1;
        end
        default: begin
            imm = instr;
            hlt = 1;
            alusrcA = 2'bxx;
            alusrcB = 2'bxx;
            alucontrol = 4'bxxxx;
            memwrite = 0;
            memtoreg = 0;
            branch = 0;
            regwrite = 0;
            jump = 0;
            jumpsrc = 0;
            alusrc_a_zero = 0;
            $display("Unknown istruction : %4h", opcode);
            $finish;
        end
    endcase

    assign inv_br = (funct3 & 3'b110) == 0 ? funct3[0] : !funct3[0];
endmodule
