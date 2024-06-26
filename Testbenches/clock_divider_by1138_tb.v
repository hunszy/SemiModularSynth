`timescale 1ns/1ns
module clock_divider_by1138_tb;

	//inputs
	reg reset_n, clk =0;
	wire new_clk;


	clock_divider_by1138 uut(.clk(clk), .reset_n(reset_n), .en(1'b1), .new_clk(new_clk));


	always begin
		#20; clk = ~clk;
	end

	initial begin

		reset_n = 0; #30;
		reset_n = 1; #80000;
		$stop;
	end
endmodule