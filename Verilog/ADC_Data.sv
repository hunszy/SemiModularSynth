// Use this module to interface the ADC on the FPGA (i.e. for Quartus)

module ADC_Data(
  input  logic        clk,
                      reset_n, // active-low
  input logic  [4:0]  channel_in,
  output logic [4:0]  channel_out,
  output logic [11:0] ADC_raw, // the latest 12-bit ADC value                                            
                      ADC_out,// moving average of ADC value, over 256 samples,   
  output logic        response_valid_out);
                               // number of samples defined by the averager module                    
                               
  parameter integer X = 4; // 4; // X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bits of resolution gained)
  logic          new_response_valid_out;
  logic [11:0]   ADC_raw_temp,ADC_out_ave,temp;
  logic [23:0]   ADC_out_upscale;
  logic [12:0]   voltage_temp;
  // below signal is not used in the design but is a sample signal if a high resolution signal is required
  logic [X+11:0] Q_high_res; // (4+11 DOWNTO 0); -- first add (i.e. X) is log4(2**N), e.g. log4(2**8) = log4(256) = 4, must match X constant

//==========================================================================
//== Uncomment one of the two ADC modules below, depending on the purpose ==
//==========================================================================
  // Instantiate RTL ADC (i.e. for Quartus)
   ADC_Conversion ADC_ins(
     .MAX10_CLK1_50      (clk),
     .channel            (channel_in),
     .response_valid_out (response_valid_out),
     .ADC_out            (ADC_raw_temp),
     .channel_out        (channel_out)); 

  
//  // Instantiate Simulation ADC (i.e. for ModelSim)
// ADC_Simulation ADC_ins(
//   .MAX10_CLK1_50      (clk),
//   .response_valid_out (response_valid_out),
//   .ADC_out            (ADC_raw_temp)); 

//==========================================================================
    
  averager256 #( // change parameters here to modify the number of samples to average
    .N(8),     // 8, 10, -- log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
    .X(4),     // 4, 5, -- X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bit of resolution gained)
    .bits(12)) // 11 -- number of bits in the input data to be averaged
    
  averager( // below are the connections for the instantiation
    .clk     (clk),
    .reset_n (reset_n),
    .EN      (new_response_valid_out),
    .Din     (ADC_raw_temp),
    .Q       (ADC_out_ave));
    
  assign ADC_out = ADC_out_ave;
  assign ADC_out_upscale = ADC_raw_temp * 8'd47;
  assign ADC_raw = ADC_out_upscale[16:5];
  assign voltage = voltage_temp;

  assign voltage_temp = ADC_out_ave*2500*2/(2**12); //voltage_temp = ADC_out_ave*2500*2/(2**12);
/*************************
Above voltage_temp equation (voltage_temp = ADC_out_ave*2500*2/(2**12)):  
2**12 represents 2^12 = 4096, and this is scaling factor to normalize the ADC 12-bit 
value to 1 (technically 4095/4096 = 0.9997559). Dividing by 4096 is trivial for digital 
hardware, it's just a shift of the binary point. Dividing by 4095 is difficult, 
resulting a complex divider that reduces the Fmax to 21.1 MHz. The difference in 
accuracy between /4096 and /4095 is neglible for this application. If you are curious, 
talk to Denis Onen about how to efficiently compute /4095, he has expertise in these 
kinds of calculations.

2500*2 represents the scaling factor to convert the normalized 12-bit ADC value to the 
ratiometric voltage value, in milli-volts (mV). The ADC accepts a 2.5 V input signal 
(2500 mV) and converts it to a 12-bit ratiometric number. However, there is a 2:1 voltage 
divider before the ADC input, so the actual input voltage range is 0V - 5V, which gets 
converted to a 12-bit ratiometric number. So, 2500*2 is 5000, but is written as 2500*2 
to give the user the hint that there is voltage division going on at the ADC input.  
***********************************************************/  
endmodule
