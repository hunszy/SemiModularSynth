module clock_divider_by1138(input wire clk, en, reset_n,
                            output reg new_clk);
					 
	reg [10:0] counter;
				
	always @(posedge clk, negedge reset_n) begin
		if(!reset_n) begin
			counter <= 0;
			new_clk <= 0;
		end
		else begin
			counter <= counter + 1;
			if(counter > 568) begin
				counter <= 0;
				new_clk <= !new_clk;
			end
		end
	end
		
endmodule