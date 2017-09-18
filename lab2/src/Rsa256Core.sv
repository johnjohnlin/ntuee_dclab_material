module Rsa256Core(
	input i_clk,
	input i_rst,
	input         src_val,
	output logic  src_rdy,
	input [255:0] i_a,
	input [255:0] i_e,
	input [255:0] i_n,
	output logic         result_val,
	input                result_rdy,
	output logic [255:0] o_a_pow_e
);
endmodule
