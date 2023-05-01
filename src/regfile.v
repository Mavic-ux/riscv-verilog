module regfile(
    input clk,
    input [4:0] ra1, ra2,
    input we3,
    input [4:0] wa3,
    input [31:0] wd3,
    output [31:0] rd1, rd2
);
    reg [31:0] registers [31:0];

    assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
    assign rd2 = (ra2 != 0) ? registers[ra2] : 0;

    always @ (negedge clk) begin
        if (we3) begin 
            registers[wa3] <= wd3;
        end
        
        for (integer i = 0; i < `WORD; i = i + 2) begin
            $display("registers[%0d]\t - \t 0x%32h  registers[%0d]\t - \t 0x%32h" , i, registers[i], i + 1, registers[i + 1]);
        end
        $display("\n");
    end
endmodule
