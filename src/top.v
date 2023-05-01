`include "consts.v"

module top (
    input clk, reset,
    output [(`WORD - 1):0] writedata, dataadr,
    output memwrite
);
    logic [(`WORD - 1):0] pc /* verilator public */;
    logic [(`WORD - 1):0] instr, readdata;
    
    cpu cpu (.clk(clk), .reset(reset),
            .pc(pc), .instr(instr),
            .memwrite(memwrite), .aluout(dataadr), .writedata(writedata),
            .readdata(readdata));
    instrmem #(18) instrmem (.a(pc[19:2]), .rd(instr));
    datamem #(18) datamem (.clk(clk), .we(memwrite),
                     .a(dataadr), .wd(writedata), .rd(readdata));
endmodule
