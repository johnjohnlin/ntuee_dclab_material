module ReadPipeline(
	input i_clk,
	input i_rst,
	output logic         data_val,
	input                data_rdy,
	output logic [255:0] o_a,
	output logic [255:0] o_n,
	output logic [255:0] o_e,
	output logic [4:0]  o_address,
	output logic        o_ren,
	input               i_wait,
	input               i_readdatavalid,
	input        [31:0] i_readdata,
	input i_sent
);

endmodule

module WritePipeline(
	input i_clk,
	input i_rst,
	input                result_val,
	output logic         result_rdy,
	input        [255:0] i_a_pow_e,
	output logic [4:0]  o_address,
	output logic        o_ren,
	output logic        o_wen,
	input               i_wait,
	input               i_readdatavalid,
	input        [31:0] i_readdata,
	output logic [31:0] o_writedata,
	output logic o_sent
);

endmodule

module Rsa256Wrapper(
	input avm_rst,
	input avm_clk,
	output logic [4:0]  avm_address,
	output logic        avm_read,
	output logic        avm_write,
	input               avm_waitrequest,
	input               avm_readdatavalid,
	input        [31:0] avm_readdata,
	output logic [31:0] avm_writedata
);
	// Feel free to use TA's template, of course you can use yours
	logic        wp_ren;
	logic        wp_wen;
	logic [4:0]  wp_addr;
	logic        rp_ren;
	logic [4:0]  rp_addr;
	logic sent;
	logic rsa_out_val;
	logic rsa_out_rdy;
	logic [255:0] rsa_enc;
	logic [255:0] rsa_e;
	logic [255:0] rsa_n;
	logic rsa_in_val;
	logic rsa_in_rdy;
	logic [255:0] rsa_dec;
	assign avm_read = rp_ren || wp_ren;
	assign avm_write = wp_wen;
	always_comb begin
		unique case (1'b1)
			(wp_ren||wp_wen): begin avm_address = wp_addr; end
			rp_ren: begin avm_address = rp_addr; end
			default: begin avm_address = 0; end
		endcase
	end
	Rsa256Core u_core(
		.i_clk(avm_clk),
		.i_rst(avm_rst),
		.src_val(rsa_in_val),
		.src_rdy(rsa_in_rdy),
		.i_a(rsa_enc),
		.i_e(rsa_e),
		.i_n(rsa_n),
		.result_val(rsa_out_val),
		.result_rdy(rsa_out_rdy),
		.o_a_pow_e(rsa_dec)
	);
	ReadPipeline u_read(
		.i_clk(avm_clk),
		.i_rst(avm_rst),
		// to core
		.data_val(rsa_in_val),
		.data_rdy(rsa_in_rdy),
		.o_a(rsa_enc),
		.o_e(rsa_e),
		.o_n(rsa_n),
		// avalon
		.o_address(rp_addr),
		.o_ren(rp_ren),
		.i_wait(avm_waitrequest),
		.i_readdatavalid(avm_readdatavalid),
		.i_readdata(avm_readdata),
		// write pipeline
		.i_sent(sent)
	);
	WritePipeline u_write(
		.i_clk(avm_clk),
		.i_rst(avm_rst),
		// from core
		.result_val(rsa_out_val),
		.result_rdy(rsa_out_rdy),
		.i_a_pow_e(rsa_dec),
		// avalon
		.o_address(wp_addr),
		.o_ren(wp_ren),
		.o_wen(wp_wen),
		.i_wait(avm_waitrequest),
		.i_readdatavalid(avm_readdatavalid),
		.i_readdata(avm_readdata),
		.o_writedata(avm_writedata),
		// read pipeline
		.o_sent(sent)
	);
endmodule
