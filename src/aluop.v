`define ALU_ADD 4'b0000
`define ALU_SUB 4'b1000
`define ALU_SLL 4'b0001
`define ALU_SLT 4'b0010
`define ALU_SLTU 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SRL 4'b0101
`define ALU_SRA 4'b1101
`define ALU_OR 4'b0110
`define ALU_AND 4'b0111


`define ALU_INSTR_ADDI   3'b0
`define ALU_INSTR_ADD    3'b0
`define ALU_INSTR_BEQ    3'b000
`define ALU_INSTR_BNE    3'b001
`define ALU_INSTR_BLT    3'b100
`define ALU_INSTR_BGE    3'b101
`define ALU_INSTR_BLTU   3'b110
`define ALU_INSTR_BGEU   3'b111


`define ALU_SRCA_REG 2'b00
`define ALU_SRCA_PC  2'b01
`define ALU_SRCB_REG 2'b00
`define ALU_SRCB_IMM 2'b01
`define ALU_SRCB_FOUR 2'b10
