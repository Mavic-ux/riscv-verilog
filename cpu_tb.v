`include "cpu.v"

module stimulus ();
    
    reg clock;
    reg reset;
    wire zero;

    cpu test_processor(clock,reset,zero);

    initial begin
        $dumpfile("output_wave.vcd");
        $dumpvars(0,stimulus);
    end

    initial begin
        reset = 1;
        #50 reset = 0;
    end

    initial begin
        clock = 0;
        forever #20 clock = ~clock;
    end

    initial
    #1000 $finish;
    
endmodule
