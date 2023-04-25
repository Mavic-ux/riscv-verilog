`include "reg_file.v"
`include "alu.v"

module datapath(
    input [4:0]read_reg_num1,
    input [4:0]read_reg_num2,
    input [4:0]write_reg,
    input [3:0]alu_control,
    input regwrite,
    input clock,
    input reset,
    output zero_flag
);

    wire [31:0]read_data1;
    wire [31:0]read_data2;
    wire [31:0]write_data;

    reg_file reg_file_module(
    read_reg_num1,
    read_reg_num2,
    write_reg,
    write_data,
    read_data1,
    read_data2,
    regwrite,
    clock,
    reset
    );

    alu alu_module(read_data1, read_data2, alu_control, write_data, zero_flag);
	 
endmodule
