module fetch_stage import jasc_pkg::*
	(
		output if_id_t         if_id,
		
		input logic [31:0]     pc,
		
		// IMEM Interface
		output imem_req_t       imem_req,
		input imem_rsp_t        imem_rsp
	);
	
		
	always_comb begin
		imem_req.valid = 1'b1;
		imem_req.pc    = pc;

		if_id.valid = fetch_rsp.valid;
		if_id.instr = fetch_rsp.instr;
		if_id.pc    = pc;
	end


endmodule