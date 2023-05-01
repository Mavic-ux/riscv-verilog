module datamem #(parameter POWER = 20)(
    input clk, we,
    input [(`WORD - 1):0] a, wd,
    output [(`WORD - 1):0] rd
);
    reg [(`WORD - 1):0] buffer [((1 << POWER) - 1):0];
    assign rd = buffer[a]; 
    always @ (posedge clk)
        if (we)
            buffer[a] <= wd;
endmodule
