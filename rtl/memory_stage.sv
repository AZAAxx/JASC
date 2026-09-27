module memory_stage import jasc_pkg::*
	(
		input ex_mem_t         ex_mem,
		output mem_wb_t        mem_wb,
		
		// DMEM interface
		output dmem_req_t       dmem_req,
		input dmem_rsp_t        dmem_rsp
	);
	
	
	always_comb begin
		mem_wb = '0;
		
		mem_wb.ctrl           = ex_mem.ctrl;
		mem_wb.info           = ex_mem.info;
		mem_wb.imm            = ex_mem.imm;
		
		mem_wb.info.mem_addr  = '0;   // memory interface
		mem_wb.info.mem_rmask = '0;
		mem_wb.info.mem_wmask = '0;
		mem_wb.info.mem_rdata = '0;
		mem_wb.info.mem_wdata = '0;
		
		dmem_req = '0;
		unique case (ex_mem.ctrl.mem_op) begin
			MEM_LOAD: begin
					dmem_req.valid        = 1'b0;
					dmem_req.addr         = ex_mem.alu_res;
					dmem_req.we           = 1'b0;
					dmem_req.wdata        = '0;
					dmem_req.wstrb        = ex_mem.info.mem_byte_en;
					
					mem_wb.valid          = dmem_rsp.valid;
					mem_wb.info.mem_addr  = ex_mem.alu_res;
					mem_wb.info.mem_rmask = ex_mem.info.mem_byte_en;
					mem_wb.info.mem_rdata = dmem_rsp.rdata;
				end
			MEM_STORE: begin
					dmem_req.valid        = 1'b0;
					dmem_req.addr         = ex_mem.alu_res;
					dmem_req.we           = 1'b1;
					dmem_req.wdata        = ex_mem.info.rs2_rdata;
					dmem_req.wstrb        = ex_mem.info.mem_byte_en;
					
					mem_wb.valid          = dmem_rsp.valid;
					mem_wb.info.mem_addr  = ex_mem.alu_res;
					mem_wb.info.mem_wmask = ex_mem.info.mem_byte_en;
					mem_wb.info.mem_wdata = ex_mem.info.rs2_rdata;
				end
			MEM_NONE: begin
					dmem_req.valid        = 1'b0;
					
					mem_wb.valid          = ex_mem.valid;
				end
		endcase
		
	end
	

endmodule