// approximately exponential incrementer controller
module approx_exp_inc_control
#( parameter
  CLK_FREQ = 1_000_000, 
  MAX_TIME_MS = 2000,
  ACCURACY = 16,  // number of chunks to break up the time period into 
  // Each chunk of the exponential will be approximated linearly
  // This will be rounded up to the next power of 2
  WIDTH = 10,
  REVERSE = 0  // 0: slow to fast,  1: fast to slow
  ) (
    input clk, reset, start,
    input [WIDTH-1:0] max_out,
    input [WIDTH-1:0] pulse_length,  // max value ~= MAX_TIME_MS, 0 = very short
    output inc_control
  );

  // cycles: clock cycles
  localparam BLOCKS_LOG2 = $clog2(ACCURACY);
  localparam BLOCKS      = 1 << BLOCKS_LOG2;
  localparam MAX_CYCLES = (CLK_FREQ/1000) * MAX_TIME_MS;
  localparam VARIABLE_SIZE = $clog2(MAX_CYCLES);

  reg [2:0] Running; 
  reg IncControl;
  assign inc_control = IncControl;

  reg [VARIABLE_SIZE-1:0] TotalCycles;
  reg [VARIABLE_SIZE-1:0] CyclesPerBlock;
  reg [VARIABLE_SIZE-1:0] CyclesPerInc;
  reg [VARIABLE_SIZE-1:0] CounterBlock;
  reg [VARIABLE_SIZE-1:0] CounterInc;

  always @(posedge clk) begin  
    if (reset) begin
      CounterBlock <= 0;
      CounterInc   <= 0;
      CyclesPerInc <= 0;
      TotalCycles  <= 0;
      Running      <= 0;
    end else begin
      if (start || (Running < 3)) begin
        Running = start ? 0 : Running + 1;
        TotalCycles    <= (MAX_CYCLES * (pulse_length + 1)) >> WIDTH;
        CyclesPerBlock <= TotalCycles >> BLOCKS_LOG2;
        CyclesPerInc   <= REVERSE ?
          (2 * CyclesPerBlock - (CyclesPerBlock >> BLOCKS)) / max_out :
          ((CyclesPerBlock << BLOCKS) - CyclesPerBlock) / max_out;
        CounterBlock   <= 0;
        CounterInc     <= 0;
      end else begin
        if (CounterBlock >= CyclesPerBlock) begin
          CounterBlock <= 0;
          CyclesPerInc <= REVERSE ? CyclesPerInc<<1 : CyclesPerInc>>1;
        end else 
          CounterBlock <= CounterBlock + 1;

        if (CounterInc >= CyclesPerInc) begin
          CounterInc <= 0;
          IncControl <= 1;
        end else begin
          CounterInc <= CounterInc + 1;
          IncControl <= 0;
        end 
      end
    end
  end

  endmodule