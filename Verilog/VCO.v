module VCO
    (input          wire clk, sample_clk, //assume 24 MHz clock, 44.1 kHz sample clock
     input          wire reset_n,
     input          wire [1:0] wave_type,           //00 = square, 01 = triangle, 10 = sawtooth, 11 = sine
     input          wire [9:0] frequency_in,        //frequency input from ESP32 polling control panel
     input          wire [9:0] mod_in,              //modulation amount from low-res adc from patch-bay
     output         reg [15:0] d_out                //44.1(ish) kHz sample rate
	);
	reg  [17:0] upscaled_index;
	wire        new_clk;
	wire [9:0]  index;
	wire [15:0] sqr_out, saw_out;
	reg  [15:0] sin_out, tri_out;
	reg  [15:0] my_rom [1023:0];

	
	assign index = upscaled_index[17:8];

	//determine sin from lut
	always @(posedge sample_clk, negedge reset_n) begin
		if(!reset_n) begin
			upscaled_index <= 0;
			sin_out <= 0;
		end
		else begin
			//"magic line" ---> see excel file "LUT index calcs" for more info
			upscaled_index <= upscaled_index + 130 + frequency_in * 4 + (mod_in);
			sin_out <= my_rom[index];
		end
	end
	
	initial begin
		$readmemh("LUT.txt",my_rom);
	end
	
	//determine square wave output
	assign sqr_out[15:0] = {16{index[9]}};
	
	//determine triangle wave output
	always @(*) begin
		if(upscaled_index[17] == 0)
			tri_out = upscaled_index[16:1];
		else
			tri_out = 1 - upscaled_index[16:1];
	end
	
	//determine sawtooth output
	assign saw_out = upscaled_index[17:2];
	
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