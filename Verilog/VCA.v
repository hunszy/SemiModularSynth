module VCA(
    input wire [9:0] volume,
    input wire [15:0] sig_in,
    output wire [15:0] sig_out
);

    wire [25:0] multiplied_num;

    //assign multiplied_num = (sig_in * volume);
	assign multiplied_num = (sig_in * volume);
    assign sig_out = multiplied_num[25:10];

endmodule