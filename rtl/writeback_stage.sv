module writeback_stage import jasc_pkg::*
	(
		input mem_wb_t         mem_wb;
		
		// Register File interface
		output logic [4:0]     rd_addr,
		output logic [31:0]    rd_wdata;
		output logic           rd_write_en;
	);

	
	
	
	///////////////
	// WRITEBACK //
	///////////////
	
	
	//update register file, MUX for rd_wdata
	always_comb begin
		unique case (ctrl.rd_wdata_sel)
		
		endcase
	end
	
	
	// NEXT CYCLE
	always_ff @(posedge clk)
		if (!rst_n)
			pc_q <= '0;     // TODO: find a good reset value
		else
			pc_q <= pc_d;
	end
	
	
	
endmodule