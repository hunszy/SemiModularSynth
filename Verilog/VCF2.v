module VCF2(
    input wire clk, reset_n, LPF, sample_clk,
    input wire [9:0] cutoff,
    input wire [15:0] sig_in,
    output reg [15:0] sig_out
);

    reg [16:0] x;
    reg [16:0] y_del1;
    reg [32:0] filter_out;

    wire [15:0] beta;
    wire pulse_new_sample;

    pulse_sampler ps_ins(.clk(clk), .D(sample_clk), .Qout(pulse_new_sample));

    assign beta = {cutoff, 6'b000000};

/*
    assign term1 = ((b0[16] ? ~b0[15:0] + 1 : b0[15:0]) * x) / 2**15;
    assign term2 = ((b1[16] ? ~b1[15:0] + 1 : b1[15:0]) * x_del1) / 2**15;
    assign term3 = ((b2[16] ? ~b2[15:0] + 1 : b2[15:0]) * x_del2) / 2**15;
    assign term4 = ((b3[16] ? ~b3[15:0] + 1 : b3[15:0]) * x_del3) / 2**15;
    assign term5 = ((a1[16] ? ~a1[15:0] + 1 : a1[15:0]) * y_del1) / 2**15;
    assign term6 = ((a2[16] ? ~a2[15:0] + 1 : a2[15:0]) * y_del2) / 2**15;
    assign term7 = ((a3[16] ? ~a3[15:0] + 1 : a3[15:0]) * y_del3) / 2**15;
*/
    always @(*)begin
        if(filter_out[32] == 1)
            sig_out = 0;
        else
            sig_out = filter_out[31:16];
    end

    always @(posedge clk, negedge reset_n)begin
        if(!reset_n) begin
            x <= 0;
            y_del1 <= 0;
            filter_out <= 0;
        end
        else begin
            if(pulse_new_sample) begin
                x <= sig_in;
                filter_out <= (x*beta + y_del1*(16'b1111_1111_1111_1111 - beta));
                y_del1 <= filter_out[31:16];
            end                                                                  
        end
    end

endmodule