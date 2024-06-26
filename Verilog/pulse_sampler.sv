module pulse_sampler
    #(parameter width=1)
    (input  logic   clk, D,
    output  logic   Qout);

    logic   Q;

    always_ff @ (posedge clk)
        Q <= D;

    always_comb
        Qout = ((!Q) & D);

endmodule