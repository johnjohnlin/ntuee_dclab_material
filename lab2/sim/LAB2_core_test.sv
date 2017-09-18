`timescale 1ns/1ns
`include "core_include.sv"

module LAB2_core_test;

logic i_clk, i_rst;
logic [31:0] a[8], e[8], n[8], o[8];
logic [255:0] a256, e256, n256, o256;
`Pos(rst_out, i_rst)
`PosIf(ck_ev, i_clk, i_rst)
`WithFinish

always #1 i_clk = ~i_clk;
initial begin
	$fsdbDumpfile("LAB2_core_test.fsdb");
	$fsdbDumpvars(0, LAB2_core_test, "+mda");
	i_clk = 0;
	i_rst = 1;
	#1 $NicotbInit();
	#11 i_rst = 0;
	#10 i_rst = 1;
	#1000000 $display("Timeout");
	$NicotbFinal();
	$finish;
end

always@* for (int i = 0; i < 8; i++) begin
	a256[(i*32+31)-:32] = a[i];
	e256[(i*32+31)-:32] = e[i];
	n256[(i*32+31)-:32] = n[i];
	o[i] = o256[(i*32+31)-:32];
end

Rsa256Core dut(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_a(a256),
	.i_e(e256),
	.i_n(n256),
	.o_a_pow_e(o256)
);

endmodule
