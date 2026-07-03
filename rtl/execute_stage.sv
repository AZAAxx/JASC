module execute_stage import jasc_pkg::*
	(
		input id_ex_t          id_ex;
		output ex_mem_t        ex_mem;
	);
	
	
	// Implemented signals
	logic [31:0] a, b, alu_res;
	logic        flag_z, flag_n;
	logic [31:0] next_pc;
	
	
	
	///////////////////////
	// OPERAND SELECTION //
	///////////////////////
	
	always_comb begin
		a = id_ex.info.rs1_rdata;
		b = id_ex.info.rs2_rdata;
		
		unique case (id_ex.ctrl.opA_sel) 
			OPA_RF:    a = id_ex.info.rs1_rdata;
			OPA_IMM:   a = id_ex.imm;
			OPA_PC:    a = id_ex.info.pc_rdata;
			default:   a = id_ex.info.rs1_rdata;
		endcase
		
		unique case (id_ex.ctrl.opB_sel)
			OPB_RF:    b = id_ex.ctrl.rs2_rdata;
			OPB_IMM:   b = id_ex.imm;
			OPB_IMM_4: b = 32'h04;
			default:   b = id_ex.ctrl.rs2_rdata;
		endcase
	end
	
	
	
	
	/////////
	// ALU //
	/////////
	
	jasc_ALU alu (
		.a             (a),
		.b             (b),
		.alu_op        (id_ex.ctrl.alu_op),
		
		.alu_res       (alu_res),
		.flag_z        (flag_z),
		.flag_n        (flag_n)
	);
	
	
	
	/////////////
	// Next PC //
	/////////////
	
	alias rs1 = id_ex.info.rs1_rdata;
	alias rs2 = id_ex.info.rs2_rdata;
	alias pc  = id_ex.info.pc_rdata

	always_comb begin
		next_pc = pc + 1'b1;
		
		unique case (id_ex.ctrl.next_pc_sel)
			NEXTPC_BRANCH: begin
					unique case (id_ex.ctrl.branch_type)
						BRANCH_EQ:  if(rs1 == rs2)                    next_pc = pc + id_ex.imm;
						BRANCH_NE:  if(rs1 != rs2)                    next_pc = pc + id_ex.imm;
						BRANCH_LT:  if(signed'(rs1) <   signed'(rs2)) next_pc = pc + id_ex.imm;
						BRANCH_GE:  if(signed'(rs1) >=  signed'(rs2)) next_pc = pc + id_ex.imm;
						BRANCH_LTU: if(rs1 <  rs2)                    next_pc = pc + id_ex.imm;
						BRANCH_GEU: if(rs1 == rs2)                    next_pc = pc + id_ex.imm;
						default: next_pc = pc + 1'b1;
					endcase
				end
			NEXTPC_PC_1:    next_pc = pc + 1'b1;
			NEXTPC_PC_IMM:  next_pc = pc + id_ex.imm;
			NEXTPC_RS1_IMM: next_pc = rs1 + id_ex.imm;
			default:        next_pc = id_ex.info.pc_rdata + 1'b1;
		endcase
	end
	
	
	
	always_comb begin
		ex_mem = '0;
		
		ex_mem.valid          = id_ex.valid;
		ex_mem.ctrl           = id_ex.ctrl;
		ex_mem.info           = id_ex.info;
		
		ex_mem.info.pc_wdata  = next_pc;
		// memory controls?
		
		ex_mem.alu_res = alu_res
		ex_mem.flag_z = flag_z;
		ex_mem.flag_n = flag_n;
	end

endmodule