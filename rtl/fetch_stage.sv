module fetch_stage import jasc_pkg::*
	(
		output if_id_t         if_id;
	);
	
	
	logic [31:0] pc;
	logic [31:0] instr;   // for now try with hardcoded instructions
	
	
	// LOGIC for pc and instr
	
	assign if_id.valid = 1'b1;
	assign if_id.pc =  pc;
	assign if_id.instr = instr;

endmodule