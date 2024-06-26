// Moving average of 256 samples on Din

module averager256
 #(parameter int // Note, these are the generic default values. The actual values are in the instantiation.
     N    = 8,   // log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
     X    = 4,   // X does nothing in this implementation but is left in case higher level modules try and set it
     bits = 11)  // number of bits in the input data to be averaged
  (input  logic          clk,
                         EN,      // takes a new sample when high for each clock cycle
                         reset_n,
   input  logic [bits-1:0] Din,     // input sample for moving average calculation
   output logic [bits-1:0] Q);      // 12-bit moving average of 256 samples
	
	
   logic [bits-1:0] ff [2**N:0]; //flipflops to store samples	
	logic [bits+N-1:0] sum;         //total sum, will reach a max of (2^bits * 2^N) = 2^(bits + N)
	assign Q = sum[bits+N-1:N];     //output will be sum bitshifted by N (to divide by 2^N)
														 
   always_ff @(posedge clk, negedge reset_n) begin
	   if(!reset_n) begin
			sum <= 0;
			for(int i = 0; i <= 2**N; i++)
		      ff[i] <= 0;
		end
	   else begin
		   if(EN) begin
		      for(int i = 0; i < 2**N; i++)
		         ff[i] <= ff[i+1];         //set each flipflop to previous flipflop
		      ff[2**N] <= Din;           //set first flipflop to input data
			   sum <= sum + ff[2**N] - ff[0];    //add new data and subtract data from 256 samples ago
         end				
	   end
   end	
	
endmodule     

// Moving average of 2**N samples on Din.
// Note: used of Q_high_res if needed. Copied over from previous averager256.sv code.
// Code modeled after provided averager256.sv code, modified to work as adder accumulation average.

//module averager256
//    #(parameter int         // Note: Generic default values provided.  Actual values given through instantiation.
//        N       = 8,        // log2(number of samples to average over), e.g. N=8 => 2**8 = 256 samples, N=9 => 2**9 = 512 samples, etc
//        X       = 4,        // X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bits of resolution gained).  >> ask TA how this works.
//        bits    = 12)       // number of bits in the input data to be averaged.
//    (input logic            clk,
//                            EN,     // takes a new sample when high or each clock cycle.
//                            reset_n,
//    input  logic [bits-1:0] Din,    // input sample for accumlator and initial register.
//    output logic [bits-1:0] Q);     // 12-bit moving average, default is for 256 samples.
//    // output logic [bits-1:0] Q_high_res);    // commented out for standard purpose.
//                                            // ask how this works for more clarity.
//                                            // Do we actual get better resolution?
//    
//    logic [2*bits-1:0] REG_ARRAY [2**N-1:0];    // Creates 2**N registers.
//    logic [2**N-1:0] tmp_adder;                 // To hold accumulator value before subtracting final register.
//    logic [2**N-1:0] tmp_sub;                   // To hold accumulator value after subtrating final register.
//    logic [2**N-1:0] tmp_fin;                   // To hold acculmulator final value to be shifted.
//
//    always_ff @ (posedge clk, negedge reset_n)  // populate or reset shift registers.
//        if (!reset_n) begin
//            for(int i = 0; i < 2**N; i++)       // Loop1
//                REG_ARRAY[i] <= 0;              // Assign zero values to all registers upon reset.
//            Q <= 0;                             // Assign zero value to module output upon reset.
//            tmp_adder <= 0;
//            tmp_sub <= 0;
//            // Q_high_res <= 0;
//        end
//        else if (EN) begin
//            REG_ARRAY[0] <= Din;
//            for(int j = 0; j < 2**N-1; j++)       // Loop2
//                REG_ARRAY[j+1] <= REG_ARRAY[j];
//            Q <= tmp_fin[N+bits-1:N-1];             // Essentially a shift_left <<< by N bits, e.g. tmp_sub/2**N.
//            // Q_high_res = temp_sub[N+bits:N-X];   // ask about this line of code.
//            tmp_adder <= tmp_sub + REG_ARRAY[0];
//            tmp_sub <= tmp_adder - REG_ARRAY[2**N-1];
//        end
//    
//    assign tmp_fin = tmp_sub;                  //  Code and variable may be redundant, may just be able to use tmp_sub.
//endmodule

//*-----------------old code below-------*//  
//   genvar k;
//   generate
//     for(k = 1; k < (2**N)/2+1; k++) begin : LoopB1
//       assign tmp[k] = REG_ARRAY[2*k-1] + REG_ARRAY[2*k];
//     end
//   endgenerate
  
//   genvar m;
//   generate
//     for(m = (2**N)/2+1; m < (2**N); m++) begin : LoopB2
//       assign tmp[m] = tmp[2*(m-(2**N)/2)-1] + tmp[2*(m-(2**N)/2)];
//     end
//   endgenerate
  
//   assign tmplast    = tmp[(2**N)-1];
 
// endmodule

// Moving average of 256 samples on Din
// Converted from RB' and DT's VHDL design from ENEL 453 F2019
// Note, use Q_high_res if you need it. Uncomment in 3 places.

//module averager256
// #(parameter int // Note, these are the generic default values. The actual values are in the instantiation.
//     N    = 8,   // log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
//     X    = 4,   // X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bit of resolution gained)
//     bits = 11)  // number of bits in the input data to be averaged
//  (input  logic          clk,
//                         EN,      // takes a new sample when high for each clock cycle
//                         reset_n,
//   input  logic [bits:0] Din,     // input sample for moving average calculation
//   output logic [bits:0] Q);      // 12-bit moving average of 256 samples
//   // output logic [X+bits:0] Q_high_res); ) // (4+11 downto 0) -- first add (i.e. X) must match X constant in ADC_Data        
//                                           // moving average of ADC with additional bits of resolution:                           
//                                           // 256 average can give an additional 4 bits of ADC resolution, depending on conditions
//                                           // so you get 12-bits plus 4-bits = 16-bits (is this real?) 
//  logic [2*bits:0] REG_ARRAY [2**N:1];                                             
//  logic [2*bits:0] tmp [2**N:1]; 
//  
//  logic [2**N-1:0] tmplast;
//  
//  always_ff @(posedge clk, negedge reset_n) begin // shift_reg
//    if(!reset_n) begin
//      for(int i = 1; i < 2**N+1; i++) // LoopA1
//        REG_ARRAY[i] <= 0;
//      Q <= 0;
//      //Q_high_res = 0;
//    end
//    else if(EN) begin
//      REG_ARRAY[1] <= Din;
//      for(int j = 1; j < 2**N; j++) // LoopA2
//        REG_ARRAY[j+1] <= REG_ARRAY[j];
//      Q <= tmplast[N+bits:N];
//      //Q_high_res = tmplast[N+bits:N-X];
//    end
//  end
//  
//  genvar k;
//  generate
//    for(k = 1; k < (2**N)/2+1; k++) begin : LoopB1
//      assign tmp[k] = REG_ARRAY[2*k-1] + REG_ARRAY[2*k];
//    end
//  endgenerate
//  
//  genvar m;
//  generate
//    for(m = (2**N)/2+1; m < (2**N); m++) begin : LoopB2
//      assign tmp[m] = tmp[2*(m-(2**N)/2)-1] + tmp[2*(m-(2**N)/2)];
//    end
//  endgenerate
//  
//  assign tmplast    = tmp[(2**N)-1];
// 
//endmodule           
                                                           
      
                                                           