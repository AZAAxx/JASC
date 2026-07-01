module jasc_register_file (register_file_if.RegFile bus);

	logic [31:0] regs [31:0];   // create x0-x31, each 32 bits
	assign regs[0] = 0;         // x0 = 0
	
	// Read logic
	always_comb begin
		bus.regA_rdata = regs[bus.regA];
		bus.regB_rdata = regs[bus.regB];
	end
	
	// Write logic 
	always_ff (posedge bus.clk, negedge bus.rst_n) begin
		if(!bus.rst_n)       regs[31:0] <= '0;
		else if(bus.write_e) 
			if(bus.regW != '0) regs[bus.regW] <= bus.regW_wdata;
		else                 
	end

endmodule