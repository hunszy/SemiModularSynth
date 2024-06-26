`timescale 1ns/1ps

module envelope_generator_tb ();

  logic reset, clk, trigger;
  logic [9:0] a, d, s, r;
  logic [9:0]  envelope;

  envelope_generator UUT(.*);

  localparam t = 1000; //test clock period
  always #(t/2) clk = ~clk;

  initial begin
    reset = 0; clk = 0; trigger = 0; a = 0; d = 0; s = 0; r = 0;
    #(5*t); reset = 1; #(10*t); reset = 0; #(3*t);

    a = 10'h000; d = 10'h000; s = 10'h000; r = 10'h000;
    #t; trigger = 1; #10ms; trigger = 0; #10ms;
    
    a = 10'h001; d = 10'h001; s = 10'h001; r = 10'h001;
    #t; trigger = 1; #10ms; trigger = 0; #10ms;
    
    a = 10'h00f; d = 10'h00f; s = 10'h00f; r = 10'h00f;
    #t; trigger = 1; #100ms; trigger = 0; #10ms;
    
    a = 10'h0ff; d = 10'h0ff; s = 10'h0ff; r = 10'h0ff;
    #t; trigger = 1; #200ms; trigger = 0; #1000ms;

    a = 10'hfff; d = 10'hfff; s = 10'hfff; r = 10'hfff;
    #t; trigger = 1; #8000ms; trigger = 0; #2500ms;    
  end

endmodule