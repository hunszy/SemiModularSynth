`timescale 1ns/1ns
module VCO_tb;

reg          clk=0, sample_clk = 0, reset_n;
reg    [1:0] wave_type;           //00 = square, 01 = triangle, 10 = sawtooth, 11 = sine
reg    [9:0] frequency_in;        //frequency input from ESP32 polling control panel
reg    [9:0] mod_in;              //modulation amount from low-res adc from patch-bay
reg    [15:0] d_out;


	VCO uut(.*);


	always begin
		#21; clk = ~clk;
	end

	always begin
		#(21*544) sample_clk = ~sample_clk;
	end

	initial begin
		wave_type = 3; frequency_in = 1023; mod_in = 1023;
		//pulse a reset
		reset_n = 0; #50;
		reset_n = 1;
		
		//test max freq sine wave, mess with modulation
		wave_type = 3; frequency_in = 1023; mod_in = 0; #5_000_000
		wave_type = 3; frequency_in = 500; mod_in = 0;  #5_000_000
		wave_type = 3; frequency_in = 500; mod_in = 400; #5_000_000
		wave_type = 0; frequency_in = 500; mod_in = 30;  #5_000_000
		wave_type = 1; frequency_in = 500; mod_in = 0; #5_000_000
		wave_type = 2; frequency_in = 500; mod_in = 30;  #5_000_000
		
		$stop;
	end
endmodule