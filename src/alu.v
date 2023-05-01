module alu (
  input [31:0] src1,
  input [31:0] src2,
  input [3:0] alu_op,
  output reg [31:0] result,
  output reg zero
);

  always @ (src1, src2, alu_op) begin
    case (alu_op)
      `ALU_ADD: result = src1 + src2;
      `ALU_SLL: result = src1 << src2[4:0];
      `ALU_SRL: result = src1 >> src2[4:0]; 
      `ALU_XOR: result = src1 ^ src2; 
      `ALU_OR :  result = src1 | src2; 
      `ALU_AND: result = src1 & src2; 
      `ALU_SUB: result = src1 - src2; 
      `ALU_SLT: result = (src1 < src2) ? 32'b1 : 32'b0; 
      default:  result = 32'b0;
    endcase
    
    if (result == 0) begin
      zero = 1;
    end else begin
      zero = 0;
    end
  end
endmodule