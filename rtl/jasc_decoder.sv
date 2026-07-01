module jasc_decoder 
	import jasc_pkg::*
	(
	input logic [31:0]      instr;
	output ctrl_signals_t   ctrl;
	);
	
	ctrl.opcode = instr[6:0];
	
	logic [4:0] rs1, rs2, rd;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [31:0] imm;
	
	
	
	////////////////////////////////
	// Extracting standard fields //
	////////////////////////////////
	
	always_comb begin
		unique_case (opcode)
			OPCODE_OP:       // R-type encoding
				begin
					rd     = instr[11:7];
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = instr[24:20];
					func7  = instr[31:25];
					imm    = '0;
				end
			OPCODE_OP_IMM, 
			OPCODE_LOAD, 
			OPCODE_JALR, 
			OPCODE_SYSTEM:   // I-type encoding
				begin
					rd     = instr[11:7];
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = '0;
					func7  = '0;
					imm    = instr[31:20];
				end
			OPCODE_STORE:    // S-type encoding
				begin
					rd     = '0;
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = instr[24:20];
					func7  = '0;
					imm    = {instr[31:25], instr[11:7]};
				end 
			OPCODE_BRANCH:   // B-type encoding
				begin
					rd     = '0;
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = instr[24:20];
					func7  = '0;
					imm    = {instr[31], instr[7], instr[30:25], instr[11:6], 1'b0};
				end
			OPCODE_AUIPC
			OPCODE_LUI:      // U-type encoding
				begin
					rd     = instr[11:7];
					funct3 = '0;
					rs1    = '0;
					rs2    = '0;
					func7  = '0;
					imm    = {instr[31:12], 12'b0};
				end
			OPCODE_JAL:      // J-type encoding
				begin
					rd     = instr[11:7];
					funct3 = '0;
					rs1    = '0;
					rs2    = '0;
					func7  = '0;
					imm    = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
				end
		endcase
	end
	
	
	
	
	
	
	////////////////////////////////
	// Generating control signals //
	////////////////////////////////
	
	
	// ALU Control Block
	always_comb begin
		//Default Value
		ctrl.alu_op = ADD;
		ctrl.alu_mask = '1;
		
	end
	
	// Datapath control Block
	always_comb begin
		// RegFile controls (Decode)
		ctrl.rs1_sel = rs1;
		ctrl.rs2_sel = rs2;
		ctrl.rd_sel = rd;
		
		// Default values
		ctrl.opA_sel = RF;
		ctrl.opB_sel = IMM;
		ctrl.mem_op = NONE;
		ctrl.mem_addr_sel = '0;
		ctrl.mem_wdata_sel = '0;
		ctrl.next_pc_sel = PC_1;
		ctrl.rd_wdata_sel = ALU;
		ctrl.rd_write_en = 1'b0;
		
		case (opcode)
			OPCODE_OP: begin
				ctrl.opB_sel = RF;
				ctrl.reg_write_en = 1'b1;
			end
			OPCODE_OP_IMM: begin
				ctrl.reg_write_en = 1'b1;
			end
			OPCODE_LOAD: begin
				ctrl.mem_op = LOAD;
				ctrl.mem_addr_sel = ALU;
				ctrl.rd_wdata_sel = MEM;
				ctrl.rd_write_en = 1'b1;
			end
			OPCODE_STORE: begin
				ctrl.mem_op = STORE;
				ctrl.mem_addr_sel = ALU;
				ctrl.mem_wdata_sel = RF;
			end 
			OPCODE_BRANCH: begin
				ctrl.opB_sel = RF;
				ctrl.next_pc_sel = PC_IMM;
			end
			OPCODE_JAL: begin
				ctrl.opA_sel = PC;
				ctrl.opB_sel = IMM_4;
				ctrl.next_pc_sel = PC_IMM;
				ctrl.rd_write_en = 1'b1;
			end
			OPCODE_JALR: begin
				ctrl.opA_sel = PC;
				ctrl.opB_sel = IMM_4;
				ctrl.next_pc_sel = RS1_IMM;
				ctrl.rd_write_en = 1'b1;
			end
			OPCODE_LUI: begin
				ctrl.rd_wdata_sel = IMM;
				ctrl.rd_write_en = 1'b1;
			end
			OPCODE_AUIPC: begin
				ctrl.opA_sel = PC;
				ctrl.opB_sel = IMM;
				ctrl.rd_write_en = 1'b1;
			end
			OPCODE_SYSTEM: begin
				// Transfer control
			end
		endcase
	end
	
endmodule