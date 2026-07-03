module jasc_register_file 
	(
		input logic         clk,
		input logic         rst_n,
		input logic [4:0]   rs1,
		input logic [4:0]   rs2,
		input logic [4:0]   rd,
		input logic [31:0]  rd_wdata,
		input logic         rd_write_en,
		
		output logic [31:0] rs1_rdata,
		output logic [31:0] rs2_rdata
	);

	logic [31:0] regs [31:0];   // create x0-x31, each 32 bits
	assign regs[0] = 0;         // x0 = 0
	
	// Read logic
	always_comb begin
		rs1_rdata = regs[rs1];
		rs2_rdata = regs[rs2];
	end
	
	// Write logic 
	always_ff (posedge clk, negedge rst_n) begin
		if(!rst_n)       regs[31:0] <= '0;
		else if(rd_write_en) begin
				if(rd != '0) regs[rd] <= rd_wdata;
			end
		else                 
	end

endmodule