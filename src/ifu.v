`include "inst_mem.v"

module ifu(
    input clock,reset,
    output [31:0] Instruction_Code
);
reg [31:0] PC = 32'b0;  
    inst_mem instr_mem(PC,reset,Instruction_Code);

    always @(posedge clock, posedge reset)
    begin
        if(reset == 1)  
        PC <= 0;
        else
        PC <= PC+4;   
    end

endmodule