module I2cSender #(parameter BYTE=1) (
	input i_start,
	input [BYTE*8-1:0] i_dat,
	input i_clk,
	input i_rst,
	output o_finished,
	output o_sclk,
	inout o_sdat
);

endmodule
