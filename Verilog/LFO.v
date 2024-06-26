module LFO
    (input          wire clk, sample_clk, //assume 24 MHz clock, 44.1 kHz sample clock
     input          wire reset_n,
     input          wire [1:0] wave_type,           //00 = square, 01 = triangle, 10 = sawtooth, 11 = sine
     input          wire [9:0] frequency_in,        //frequency input from ESP32 polling control panel
     input          wire [9:0] pulse_width,         //pulse width (only applicable for square wave)
     output         reg [9:0] d_out                 //44.1(ish) kHz sample rate
	);
	reg  [31:0] upscaled_index;
	wire [9:0]  index;
	wire [9:0]  saw_out;
	reg  [9:0]  sin_out, tri_out, sqr_out;
	reg  [15:0] my_rom [1023:0];

	
	assign index = upscaled_index[31:22];

	//determine sin from lut
	always @(posedge sample_clk, negedge reset_n) begin
		if(!reset_n) begin
			upscaled_index <= 0;
			sin_out <= 0;
		end
		else begin
			//"magic line" ---> see excel file "LUT index calcs" for more info
			upscaled_index <= upscaled_index + 16'd9739 + frequency_in * 16'd1894;
			sin_out <= my_rom[index][15:6];
		end
	end
	
	initial begin
		$readmemh("LUT.txt",my_rom);
	end
	
	//determine square wave output
	always @(*) begin
		if(upscaled_index[31:22] > pulse_width)
			sqr_out = 1023;
		else
			sqr_out = 0;
	end	
	
	//determine triangle wave output
	always @(*) begin
		if(upscaled_index[31] == 0)
			tri_out = upscaled_index[30:21];
		else
			tri_out = 10'd1023 - upscaled_index[30:21];
	end
	
	//determine sawtooth output
	assign saw_out = upscaled_index[31:22];
	
	//output correct wave
	
	always @(*) begin
		case(wave_type)
			2'b00	:	d_out = sqr_out;
			2'b01	:	d_out = tri_out;
			2'b10	:	d_out = saw_out;
			2'b11	:	d_out = sin_out;
			default :	d_out = 0;
		endcase
	end
	
endmodule