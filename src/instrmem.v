module instrmem #(parameter POWER = 20)(
    input [(POWER - 1):0] a,
    output [(`WORD - 1):0] rd
);
    reg [(`WORD - 1):0] buffer[((1 << POWER) - 1):0] /* verilator public */;
    assign rd = buffer[a]; 
endmodule
