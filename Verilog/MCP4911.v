/* The MCP4911 is a 10-bit DAC */
module MCP4911
    (output wire SCK_PIN,
     input wire MISO_PIN,
     input wire [9:0] data_in,
     input wire clk, reset_n,
     input wire sample_clk,
     output wire MOSI_PIN,
     output wire CS_PIN);
     
     
    reg [7:0] tx; // the current byte to be transmitted
    reg tx_valid; // tells the SPI_Master block to send the current byte in tx
    wire tx_ready; // SPI_Master sets this bit to 1 when ready to send next byte
    wire rx_valid; // SPI_Master pulses this bit (1 cycle) when the slave has sent a message
    wire [7:0] rx; // the recieved byte
    wire [15:0] message;
    reg cs; // the register that holds the CS_n value
    assign CS_PIN = ~cs; // CS_n == !cs
    
  
    // 16-bit op-code for MCP4911: WRITE_n | BUFFER | GAIN_n | SHUTDOWN_n | DATA [9:0] | X [1:0]
	assign message = {1'b0,1'b0,1'b1,1'b1, data_in,1'b0,1'b0}; 

    
    
     SPI_Master SPI_Master_ins
     (.i_Rst_L(reset_n),
      .i_Clk(clk),
      .i_TX_Byte(tx),
      .i_TX_DV(tx_valid),
      .o_TX_Ready(tx_ready),
      .o_RX_DV(rx_valid),
      .o_RX_Byte(rx),
      .o_SPI_Clk(SCK_PIN),
      .i_SPI_MISO(MISO_PIN),
      .o_SPI_MOSI(MOSI_PIN)
      );
    
    reg [3:0] current_state;
    reg transmit_time;
    reg last_sample_clk;
    
    localparam [3:0] FIRST_MESSAGE = 0;
    localparam [3:0] TX_VALID_RISE_1 = 1;
    localparam [3:0] TX_VALID_FALL_1 = 2;
    localparam [3:0] WAIT_FOR_TX_READY_1 = 3;
    localparam [3:0] SECOND_MESSAGE = 4;
    localparam [3:0] TX_VALID_RISE_2 = 5;
    localparam [3:0] TX_VALID_FALL_2 = 6;
    localparam [3:0] WAIT_FOR_TX_READY_2 = 7;
    localparam [3:0] END_TX = 8;
    
    // TESTING
    assign test = last_sample_clk < sample_clk;
    
    
    always @ (posedge clk, negedge reset_n) begin // at the beginning of each clock cycle...
        
        if(!reset_n) begin
        
            cs <= 0;
            tx <= 0;
            current_state <= FIRST_MESSAGE;
            tx_valid <= 0;
            last_sample_clk <= 0;
            
        end
        
        else begin
        
            if (last_sample_clk < sample_clk) begin // check if counter has reached its max value. if it hasn't... otherwise, continue with transmission
            
                case (current_state)
                
                    FIRST_MESSAGE : begin
                        cs <= 1;
                        tx <= message[15:8];
                        current_state <= TX_VALID_RISE_1;
                    end
                    
                    TX_VALID_RISE_1 : begin
                        tx_valid <= 1;
                        current_state <= TX_VALID_FALL_1;
                    end
                    
                    TX_VALID_FALL_1 : begin
                        tx_valid <= 0;
                        current_state <= WAIT_FOR_TX_READY_1;
                    end
                    
                    WAIT_FOR_TX_READY_1 : begin
                        current_state <= tx_ready ? SECOND_MESSAGE : WAIT_FOR_TX_READY_1;
                    end
                    
                    SECOND_MESSAGE : begin
                        tx <= message[7:0];
                        current_state <= TX_VALID_RISE_2;
                    end
                    
                   TX_VALID_RISE_2 : begin
                        tx_valid <= 1;
                        current_state <= TX_VALID_FALL_2;
                    end
                    
                    TX_VALID_FALL_2 : begin
                        tx_valid <= 0;
                        current_state <= WAIT_FOR_TX_READY_2;
                    end
                    
                    WAIT_FOR_TX_READY_2 : begin
                        current_state <= tx_ready ? END_TX : WAIT_FOR_TX_READY_2;
                    end
                    
                    END_TX : begin
                        cs <= 0;
                        current_state <= FIRST_MESSAGE;
                        last_sample_clk <= sample_clk;
                    end
                    
                    default : begin
                        cs <= 0;
                        current_state <= FIRST_MESSAGE;
                        last_sample_clk <= sample_clk;
                    end
                    
                endcase
                
            end else begin 
            
                last_sample_clk <= sample_clk;
                
                
                cs <= 0; // pull the CS_n pin high
                
                
            end
        end
    end
    
endmodule