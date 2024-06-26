module envelope_generator
#( parameter 
  CLOCK_SPEED = 50_000_000,
  CONTROL_WIDTH = 10, 
  OUTPUT_WIDTH  = 10
) (
  input                      reset, clk, trigger,
  input  [CONTROL_WIDTH-1:0] a, d, s, r,
  output [OUTPUT_WIDTH-1:0]  envelope
);

  reg [2:0] State;
  reg [2:0] PreviousState;
  localparam IDLE    = 3'o0;
  localparam ATTACK  = 3'o1;
  localparam DECAY   = 3'o2;
  localparam SUSTAIN = 3'o3;
  localparam RELEASE = 3'o4;

  wire [OUTPUT_WIDTH-1:0] sustain_level;
  assign sustain_level = (OUTPUT_WIDTH > CONTROL_WIDTH) ? 
                         (s << (OUTPUT_WIDTH - CONTROL_WIDTH)) :
                         (s >> (OUTPUT_WIDTH - CONTROL_WIDTH)) ;

  reg NewTrigger;  // pulses on rising edge of trigger
  reg PreviousTrigger;

  reg StartExponential;  // pulses when state changes
  wire IncA, DecD, DecR;  // toggles for output increment/decrement corresponding to each stage

  wire HoldOutput;  // Hold the output for 5 clock cycles so the exponential module can setup
  reg [3:0] HoldOutputCounter;
  
  reg [OUTPUT_WIDTH-1:0] Output;
  assign envelope = Output;

//add signal to start exponentials when the state switches
  always @(posedge clk) begin  // This block controls the state changes
    if (reset)
      State <= IDLE;
    else if (NewTrigger)
      State <= IDLE;  // Sets output to 0, and state goes to ATTACK in next clk cycle
    else begin
      if ( State==IDLE    && trigger                      ) State <= ATTACK  ;
      if ( State==ATTACK  && Output=={OUTPUT_WIDTH{1'b1}} ) State <= DECAY   ;
      if ( State==DECAY   && Output<=sustain_level        ) State <= SUSTAIN ;
      if ( State==SUSTAIN && !trigger                     ) State <= RELEASE ;
      if ( State==RELEASE && Output=={OUTPUT_WIDTH{1'b0}} ) State <= IDLE    ;
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      PreviousTrigger <= 0;
      NewTrigger      <= 0;
    end else begin
      if (PreviousTrigger == 1'b0 && trigger == 1'b1) 
           NewTrigger <= 1;
      else NewTrigger <= 0;
      PreviousTrigger <= trigger;
    end
  end

  always @(posedge clk) begin  // This block controls StartExponential
    if (reset) begin
      PreviousState     <= IDLE;
      StartExponential  <= 0;
      HoldOutputCounter <= 0;
    end else begin
      if (State != PreviousState) begin
        StartExponential  <= 1;
        HoldOutputCounter <= 0;
      end else begin                       
        StartExponential   <= 0;
        HoldOutputCounter <= HoldOutput ? HoldOutputCounter + 1 : HoldOutputCounter;
      end
      PreviousState     <= State;
    end
  end

  assign HoldOutput = (HoldOutputCounter < 5);

  approx_exp_inc_control #(
    .WIDTH(CONTROL_WIDTH), .REVERSE(0), .CLK_FREQ(CLOCK_SPEED)
    ) incAControl (
    .clk          ( clk                  ),
    .reset        ( reset                ),
    .start        ( StartExponential     ),
    .max_out      ( {OUTPUT_WIDTH{1'b1}} ),
    .pulse_length ( a                    ),
    .inc_control  ( IncA                 )
  );
    approx_exp_inc_control #(
    .WIDTH(CONTROL_WIDTH), .REVERSE(1), .CLK_FREQ(CLOCK_SPEED)
    ) decDControl (
    .clk          ( clk                                ),
    .reset        ( reset                              ),
    .start        ( StartExponential                   ),
    .max_out      ( {OUTPUT_WIDTH{1'b1}}-sustain_level ),
    .pulse_length ( d                                  ),
    .inc_control  ( DecD                               )
  );
    approx_exp_inc_control #(
    .WIDTH(CONTROL_WIDTH), .REVERSE(1), .CLK_FREQ(CLOCK_SPEED)
    ) decRControl (
    .clk          ( clk              ),
    .reset        ( reset            ),
    .start        ( StartExponential ),
    .max_out      ( sustain_level    ),
    .pulse_length ( r                ),
    .inc_control  ( DecR             )
  );
      
  always @(posedge clk) begin  // This block controls the output
    if (reset) Output = 0;
    else if (!HoldOutput) case (State) 
      IDLE:    Output <= 0;
      ATTACK:  if (Output != {OUTPUT_WIDTH{1'b1}}) Output <= Output + IncA;
      DECAY:   if (Output != {OUTPUT_WIDTH{1'b0}}) Output <= Output - DecD;
      SUSTAIN: ;
      RELEASE: if (Output != {OUTPUT_WIDTH{1'b0}}) Output <= Output - DecR;
      default: ;
    endcase
  end

  // TODO: reset signal on new trigger

endmodule