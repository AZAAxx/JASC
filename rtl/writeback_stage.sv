module writeback_stage import jasc_pkg::*
	(
		input mem_wb_t         mem_wb,
		
		// Register File interface
		output logic [4:0]     rd_addr,
		output logic [31:0]    rd_wdata,
		output logic           rd_write_en,
	);

	
	
	
	///////////////
	// WRITEBACK //
	///////////////
	assign rd_addr = mem_wb.info.rd_addr;
	assign rd_write_en = mem_wb.ctrl.rd_write_en;
	
	
	//update register file, MUX for rd_wdata
	always_comb begin
		unique case (mem_wb.ctrl.rd_wdata_sel)
			RD_ALU: rd_wdata = mem_wb.alu_res;
			RD_MEM: rd_wdata = mem_wb.mem_rdata;
			RD_IMM: rd_wdata = mem_wb.imm;
		endcase
	end
	
	
endmodule