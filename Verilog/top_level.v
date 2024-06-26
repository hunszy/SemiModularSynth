module top_level(
	input wire  reset_n, clk, button,
	inout wire  [35:0] GPIO, 
	inout wire [15:0] ARDUINO_IO
	);

	//digital inputs
	wire  MIDI_TOGGLE, EG_TRIGGER;
	wire  [1:0] VCO_WAVE_TYPE,   LFO1_WAVE_TYPE,      LFO2_WAVE_TYPE;

	//SPI pins to ADCs
	wire  LFO1_IN_MISO_PIN,      LFO1_IN_CS_PIN,      LFO1_IN_SCK_PIN;
	wire  LFO2_IN_MISO_PIN,      LFO2_IN_CS_PIN,      LFO2_IN_SCK_PIN;
	wire  VCO_FREQ_IN_MISO_PIN,  VCO_FREQ_IN_CS_PIN,  VCO_FREQ_IN_SCK_PIN;
	wire  VCO_MOD_IN_MISO_PIN,   VCO_MOD_IN_CS_PIN,   VCO_MOD_IN_SCK_PIN;
	wire  LFO1_FREQ_IN_MISO_PIN, LFO1_FREQ_IN_CS_PIN, LFO1_FREQ_IN_SCK_PIN;
	wire  LFO2_FREQ_IN_MISO_PIN, LFO2_FREQ_IN_CS_PIN, LFO2_FREQ_IN_SCK_PIN;
	wire  VCF1_SIG_IN_MISO_PIN,  VCF1_SIG_IN_CS_PIN,  VCF1_SIG_IN_SCK_PIN;
	wire  VCA_SIG_IN_MISO_PIN,  VCA_SIG_IN_CS_PIN,  VCA_SIG_IN_SCK_PIN;

	//SPI pins to DACs
	wire  VCO_OUT_MOSI_PIN,      VCO_OUT_CS_PIN,      VCO_OUT_SCK_PIN;
	wire  LFO1_OUT_MOSI_PIN,     LFO1_OUT_CS_PIN,     LFO1_OUT_SCK_PIN;
	wire  LFO2_OUT_MOSI_PIN,     LFO2_OUT_CS_PIN,     LFO2_OUT_SCK_PIN;
	wire  VCF1_OUT_MOSI_PIN,     VCF1_OUT_CS_PIN,     VCF1_OUT_SCK_PIN;
	wire  VCA_OUT_MOSI_PIN,     VCA_OUT_CS_PIN,     VCA_OUT_SCK_PIN;
	wire  EG_OUT_MOSI_PIN,       EG_OUT_CS_PIN,       EG_OUT_SCK_PIN;

	//input signals from DE-10 ADCs ---> ADSR (for EG), VCF1 + VCA cutoff freqs
	wire [9:0] a, d, s, r, VCF1_freq_in, VCA_volume;
	wire [12:0] ADC0_out, ADC1_out, ADC2_out, ADC3_out, ADC4_out, ADC5_out;
	
	//input signals from MCP3001 ADCs
	wire[15:0] VCF1_sig_in, VCA_sig_in;
	wire [9:0] VCO_freq_in, VCO_mod_in, LFO1_freq_in, LFO2_freq_in;

	//output signals
	wire [15:0] VCO_out, VCF1_out, VCA_out;
	wire [9:0] LFO1_out, LFO2_out, EG_out;
	
	//44.1kHz clock indicating go-time for new samples
	wire sample_clk;

	//Assign digital io to signals with names ↓↓↓↓↓↓↓↓ CHANGE THIS SECTION IF PCB USES DIFFERENT PINS ↓↓↓↓↓↓↓↓↓↓↓↓↓
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//digital inputs
	assign  VFC2_TYPE = 1'b0; //unused //ARDUINO_IO[15];
	assign  VCF1_TYPE = 1'b0; //unused //GPIO[32];
	assign  MIDI_TOGGLE = 1'b0; //unused //GPIO[31];
	assign  EG_TRIGGER = ARDUINO_IO[13]; //~button;//GPIO[30];
	assign  VCO_WAVE_TYPE  = ARDUINO_IO[12:11]; //GPIO[29:28];
	assign  LFO1_WAVE_TYPE = ARDUINO_IO[5:4]; //GPIO[27:26];
	assign  LFO2_WAVE_TYPE = ARDUINO_IO[3:2]; //GPIO[25:24];
	

	//built-in ADC
	assign VCF1_freq_in = ADC3_out[11:2];
	//assign LFO1_freq_in = ADC0_out[11:2]; //for testing built-in adc
	assign d = ADC2_out[11:2];
	assign s = ADC1_out[11:2];
	assign r = ADC0_out[11:2];
	assign LFO2_freq_in = ADC4_out[11:2];
	assign LFO1_freq_in = ADC5_out[11:2];

	//SPI pins to ADCs
	/*
	assign  VCO_FREQ_IN_MISO_PIN    = GPIO[20];
	assign	GPIO[18] = VCO_FREQ_IN_CS_PIN;
	assign	GPIO[19] = VCO_FREQ_IN_SCK_PIN;
*/
	assign  VCO_MOD_IN_MISO_PIN    = GPIO[23];
	assign	GPIO[21] = VCO_MOD_IN_CS_PIN;
	assign	GPIO[22] = VCO_MOD_IN_SCK_PIN;

	//LFO1 ADC is being used for VCF freq in
	assign  LFO1_FREQ_IN_MISO_PIN    = GPIO[26];
	assign	GPIO[24] = LFO1_FREQ_IN_CS_PIN;
	assign	GPIO[25] = LFO1_FREQ_IN_SCK_PIN;

	//LFO2 ADC is being used for VCA vol in
	assign  LFO2_FREQ_IN_MISO_PIN    = GPIO[32];
	assign	GPIO[30] = LFO2_FREQ_IN_CS_PIN;
	assign	GPIO[31] = LFO2_FREQ_IN_SCK_PIN;

	assign  VCF1_SIG_IN_MISO_PIN    = GPIO[29];
	assign	GPIO[27] = VCF1_SIG_IN_CS_PIN;
	assign	GPIO[28] = VCF1_SIG_IN_SCK_PIN;

	assign  VCA_SIG_IN_MISO_PIN    = GPIO[35];
	assign	GPIO[33] = VCA_SIG_IN_CS_PIN;
	assign	GPIO[34] = VCA_SIG_IN_SCK_PIN;

	//SPI pins to DACs
	assign  GPIO[0] =  VCO_OUT_MOSI_PIN;
	assign	GPIO[1] =  VCO_OUT_CS_PIN;
	assign 	GPIO[2]	=  VCO_OUT_SCK_PIN;
	assign  GPIO[3] =  LFO1_OUT_MOSI_PIN;
	assign 	GPIO[4] =  LFO1_OUT_CS_PIN;
	assign	GPIO[5] =  LFO1_OUT_SCK_PIN;
	assign  GPIO[8:6] = {LFO2_OUT_SCK_PIN,     LFO2_OUT_CS_PIN,     LFO2_OUT_MOSI_PIN};
	assign  GPIO[14:12]  = {VCF1_OUT_SCK_PIN,     VCF1_OUT_CS_PIN,     VCF1_OUT_MOSI_PIN};
	assign  GPIO[17:15]  = {VCA_OUT_SCK_PIN,     VCA_OUT_CS_PIN,     VCA_OUT_MOSI_PIN};
	assign  GPIO[11:9]  = {EG_OUT_SCK_PIN,       EG_OUT_CS_PIN,       EG_OUT_MOSI_PIN};

	//testing pins
	//assign ARDUINO_IO[14:12] = {EG_OUT_MOSI_PIN,       EG_OUT_CS_PIN,       EG_OUT_SCK_PIN};
	//assign  ARDUINO_IO[14:12] = {VCF1_OUT_MOSI_PIN,     VCF1_OUT_CS_PIN,     VCF1_OUT_SCK_PIN};
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//create lower freq clk
	clock_divider_by1138 clkins(
		.clk(clk),
		.en(1'b1),
		.reset_n(reset_n),
		.new_clk(sample_clk)
		);

	//instantiate VCO
	VCO VCO_ins(
		.clk(clk), 
		.sample_clk(sample_clk),
		.reset_n(reset_n),
		.wave_type(VCO_WAVE_TYPE),
		.frequency_in(VCO_freq_in),
		.mod_in(VCO_mod_in),
		.d_out(VCO_out)
		);

	//instantiate LFO1
	LFO LFO1_ins(
		.clk(clk),
		.sample_clk(sample_clk),
		.reset_n(reset_n),
		.wave_type(LFO1_WAVE_TYPE),
		.frequency_in(LFO1_freq_in),
		.pulse_width(10'd512), //todo - implement this
		.d_out(LFO1_out)
		);

	//instantiate LFO2
	LFO LFO2_ins(
		.clk(clk),
		.sample_clk(sample_clk),
		.reset_n(reset_n),
		.wave_type(LFO2_WAVE_TYPE),
		.frequency_in(LFO2_freq_in),
		.pulse_width(10'd512), //todo - implement this
		.d_out(LFO2_out)
		);

	//instantiate EG
	envelope_generator EG_ins(
		.reset(!reset_n),
		.clk(clk),
		.trigger(EG_TRIGGER),
		.a(a),
		.d(d),
		.s(s),
		.r(r),
		.envelope(EG_out)
	);

 //instantiate vcf
	VCF2 VCF1_ins(
	 	.clk(clk),
		.sample_clk(sample_clk),
	 	.reset_n(reset_n),
		.LPF(1'd0),
	 	.sig_in(VCF1_sig_in), 
	 	.cutoff(VCF1_freq_in), 
	 	.sig_out(VCF1_out)
	 	);

 //instantiate vca
	VCA VCA_ins(
	 	.sig_in(VCA_sig_in), 
	 	.volume(VCA_volume), 
	 	.sig_out(VCA_out)
	 	);

//instantiate DE-10 adc sampler
	ADC_Sampler DE10_adc_ins(
		.sample_clk(sample_clk),
		.clk(clk),
		.reset_n(reset_n),
		.ADC0_out(ADC0_out),
		.ADC1_out(ADC1_out),
		.ADC2_out(ADC2_out),
		.ADC3_out(ADC3_out),
		.ADC4_out(ADC4_out),
		.ADC5_out(ADC5_out)
	);

    //instantiate SPI blocks
    MCP4911 SPI_VCO_OUT(
        .SCK_PIN(VCO_OUT_SCK_PIN),
        .MISO_PIN(),
        .data_in(VCO_out[15:6]),
        .MOSI_PIN(VCO_OUT_MOSI_PIN),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCO_OUT_CS_PIN)
        );


	MCP3001 SPI_VCO_FREQ_IN(
        .SCK_PIN(VCO_FREQ_IN_SCK_PIN),
        .MISO_PIN(VCO_FREQ_IN_MISO_PIN),
        .data_out(VCO_freq_in),
        .MOSI_PIN(),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCO_FREQ_IN_CS_PIN)
        ); 


	MCP3001 SPI_VCO_MOD_IN(
        .SCK_PIN(VCO_MOD_IN_SCK_PIN),
        .MISO_PIN(VCO_MOD_IN_MISO_PIN),
        .data_out(VCO_mod_in),
        .MOSI_PIN(),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCO_MOD_IN_CS_PIN)
        );   

    MCP4911 SPI_LFO1_OUT(
        .SCK_PIN(LFO1_OUT_SCK_PIN),
        .MISO_PIN(0),
        .data_in(LFO1_out),
        .MOSI_PIN(LFO1_OUT_MOSI_PIN),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(LFO1_OUT_CS_PIN)
        );
/*
	MCP3001 SPI_LFO1_FREQ_IN(
        .SCK_PIN(LFO1_FREQ_IN_SCK_PIN),
        .MISO_PIN(LFO1_FREQ_IN_MISO_PIN),
        .data_out(VCF1_freq_in),
        .MOSI_PIN(),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(LFO1_FREQ_IN_CS_PIN)
        );
*/
	MCP4911 SPI_LFO2_OUT(
        .SCK_PIN(LFO2_OUT_SCK_PIN),
        .MISO_PIN(),
        .data_in(LFO2_out),
        .MOSI_PIN(LFO2_OUT_MOSI_PIN),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(LFO2_OUT_CS_PIN)
        );

	MCP3001 SPI_LFO2_FREQ_IN(
        .SCK_PIN(LFO2_FREQ_IN_SCK_PIN),
        .MISO_PIN(LFO2_FREQ_IN_MISO_PIN),
        .data_out(VCA_volume),
        .MOSI_PIN(),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(LFO2_FREQ_IN_CS_PIN)
        );

	MCP4911 SPI_VCF1_SIG_OUT(
        .SCK_PIN(VCF1_OUT_SCK_PIN),
        .MISO_PIN(),
        .data_in(VCF1_out[15:6]),
        .MOSI_PIN(VCF1_OUT_MOSI_PIN),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCF1_OUT_CS_PIN)
        );

	MCP3001 SPI_VCF1_SIG_IN(
        .SCK_PIN(VCF1_SIG_IN_SCK_PIN),
        .MISO_PIN(VCF1_SIG_IN_MISO_PIN),
        .data_out(VCF1_sig_in[15:6]),
        .MOSI_PIN(),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCF1_SIG_IN_CS_PIN)
        );
	//set lower bits to 0
	assign VCF1_sig_in[5:0] = 6'b00_0000;

	MCP4911 SPI_VCA_SIG_OUT(
        .SCK_PIN(VCA_OUT_SCK_PIN),
        .MISO_PIN(),
        .data_in(VCA_out[15:6]),
        .MOSI_PIN(VCA_OUT_MOSI_PIN),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCA_OUT_CS_PIN)
        );

	//set lower bits to 0
	assign VCA_sig_in[5:0] = 6'b00_0000;

	MCP3001 SPI_VCA_SIG_IN(
        .SCK_PIN(VCA_SIG_IN_SCK_PIN),
        .MISO_PIN(VCA_SIG_IN_MISO_PIN),
        .data_out(VCA_sig_in[15:6]),
        .MOSI_PIN(),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(VCA_SIG_IN_CS_PIN)
        );
/*
	MCP4911 SPI_EG_SIG_OUT(
        .SCK_PIN(EG_OUT_SCK_PIN),
        .MISO_PIN(),
        .data_in(EG_out),
        .MOSI_PIN(EG_OUT_MOSI_PIN),
        .clk(clk),
        .reset_n(reset_n),
        .sample_clk(sample_clk),
        .CS_PIN(EG_OUT_CS_PIN)
        );    
*/
endmodule
