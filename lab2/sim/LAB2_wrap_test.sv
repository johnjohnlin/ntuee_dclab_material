`timescale 1ns/1ns
`include "wrapper_include.sv"

module LAB2_wrap_test;

logic i_clk, i_rst;
`Pos(rst_out, i_rst)
`PosIf(ck_ev, i_clk, i_rst)
`WithFinish

always #1 i_clk = ~i_clk;
initial begin
	$fsdbDumpfile("LAB2_wrap_test.fsdb");
	$fsdbDumpvars(2, dut, "+mda");
	i_clk = 0;
	i_rst = 1;
	#1 $NicotbInit();
	#11 i_rst = 0;
	#10 i_rst = 1;
	#1000000 $display("Timeout");
	$NicotbFinal();
	$finish;
end

Rsa256Wrapper dut(i_rst, i_clk);

endmodule
