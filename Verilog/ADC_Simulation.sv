// Use this module to simulate the ADC (i.e. for Modelsim)
`timescale 1ns/1ps
module ADC_Simulation(
  input  MAX10_CLK1_50,
  output response_valid_out, 
  output [11:0] ADC_out);
    
  //assign ADC_out[11:5] = 7'b100_0110; // upper ADC bits stay the same
  
  logic [4:0] count = 0;
  logic response_valid_out_i;
  int data_sample = 0;

  
  
  always begin // This models a 1 MSps ADC output, however your ADC has 25 kHz ADC output     
    response_valid_out_i = 0; #980;
    response_valid_out_i = 1; #20;
	data_sample++;
  end
  
  always_ff @(posedge response_valid_out_i) // This models the noise (lower bits), useful to check the averager
    count++;

  assign ADC_out[4:0]  = count;
  assign response_valid_out = response_valid_out_i;
  
endmodule  
