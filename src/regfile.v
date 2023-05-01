module regfile(
    input clk,
    input [4:0] rn1, rn2,
    input we,
    input [4:0] wn,
    input [(`WORD - 1):0] wd,
    output [(`WORD - 1):0] rd1, rd2
);
    reg [(`WORD - 1):0] registers [(`WORD - 1):0];

    assign rd1 = (rn1 != 0) ? registers[rn1] : 0;
    assign rd2 = (rn2 != 0) ? registers[rn2] : 0;

    always @ (negedge clk) begin
        if (we) begin 
            registers[wn] <= wd;
        end
        
        for (integer i = 0; i < `WORD; i = i + 2) begin
            $display("registers[%0d]\t - \t 0x%32h  registers[%0d]\t - \t 0x%32h" , i, registers[i], i + 1, registers[i + 1]);
        end
        $display("\n");
    end
endmodule
