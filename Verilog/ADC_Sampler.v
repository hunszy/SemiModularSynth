module ADC_Sampler(
    input wire sample_clk, clk, reset_n,
    output reg [11:0] ADC0_out, ADC1_out, ADC2_out, ADC3_out, ADC4_out, ADC5_out
);
    reg [4:0] ADC_selector;
    wire [4:0] channel_out;
    wire [11:0] ADC_out;
    wire response_valid_out;
    wire pulse_rvo;

    reg [15:0] counter;

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            ADC0_out <= 12'h0000;
            ADC1_out <= 12'h0000;
            ADC2_out <= 12'h0000;
            ADC3_out <= 12'h0000;
            ADC4_out <= 12'h0000;
            ADC5_out <= 12'h0000;
        end 
        else begin
            if(pulse_rvo) begin
                if(channel_out == 5'b00000) begin
                    ADC0_out <= ADC_out;
                    ADC_selector <= 5'b00001;
                end
                if(channel_out == 5'b00001) begin
                    ADC1_out <= ADC_out;
                    ADC_selector <= 5'b00010;
                end
                if(channel_out == 5'b00010) begin
                    ADC2_out <= ADC_out;
                    ADC_selector <= 5'b00011;
                end
                if(channel_out == 5'b00011) begin
                    ADC3_out <= ADC_out;
                    ADC_selector <= 5'b00100;
                end
                if(channel_out == 5'b00100)begin
                    ADC4_out <= ADC_out;
                    ADC_selector <= 5'b00101;
                end
                if(channel_out == 5'b00101)begin
                    ADC5_out <= ADC_out;
                    ADC_selector <= 5'b00000;
                end
            end
        end
    end

	ADC_Data(
		.clk(clk),
		.reset_n(reset_n),
		.channel_in(ADC_selector),
        .channel_out(channel_out),
		.ADC_raw(ADC_out),
        .response_valid_out(response_valid_out)
	);

pulse_sampler psins(
    .clk(clk),
    .D(response_valid_out),
    .Qout(pulse_rvo));


endmodule