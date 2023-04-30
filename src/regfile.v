module regfile(
    input clk,
    input [4:0] ra1, ra2,
    input we3,
    input [4:0] wa3,
    input [31:0] wd3,
    output [31:0] rd1, rd2
);
    reg [31:0] registers[31:0];

    assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
    assign rd2 = (ra2 != 0) ? registers[ra2] : 0;

    always @ (negedge clk)
        if (we3)
            registers[wa3] <= wd3;
endmodule
