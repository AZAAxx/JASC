module jasc_decoder import jasc_pkg::*
	(
		input logic [31:0]    instr,
		
		output ctrl_signals_t ctrl,
		output logic [4:0]    rs1,
		output logic [4:0]    rs2,
		output logic [4:0]    rd,
		output logic [31:0]   imm 
	);
	
	
	logic [6:0] opcode = instr[6:0];
	
	logic [2:0] funct3;
	logic [6:0] funct7;	
	logic [4:0] rd, rs1, rs2;
	logic [31:0] imm;
	
	
	////////////////////////////////
	// Extracting standard fields //
	////////////////////////////////
	
	always_comb begin
		unique case (opcode)
			OPCODE_OP:       // R-type encoding
				begin
					rd     = instr[11:7];
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = instr[24:20];
					funct7 = instr[31:25];
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
					funct7 = '0;
					imm    = signed'(instr[31:20]);
				end
			OPCODE_STORE:    // S-type encoding
				begin
					rd     = '0;
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = instr[24:20];
					funct7 = '0;
					imm    = signed'({instr[31:25], instr[11:7]});
				end 
			OPCODE_BRANCH:   // B-type encoding
				begin
					rd     = '0;
					funct3 = instr[14:12];
					rs1    = instr[19:15];
					rs2    = instr[24:20];
					funct7 = '0;
					imm    = signed'({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
				end
			OPCODE_AUIPC,
			OPCODE_LUI:      // U-type encoding
				begin
					rd     = instr[11:7];
					funct3 = '0;
					rs1    = '0;
					rs2    = '0;
					funct7 = '0;
					imm    = {instr[31:12], 12'b0};
				end
			OPCODE_JAL:      // J-type encoding
				begin
					rd     = instr[11:7];
					funct3 = '0;
					rs1    = '0;
					rs2    = '0;
					funct7 = '0;
					imm    = signed'({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
				end
			default: begin
					rd     = '0;
					funct3 = '0;
					rs1    = '0;
					rs2    = '0;
					funct7 = '0;
					imm    = '0;
				end
		endcase
	end
	
	
	
	
	
	////////////////////////////////
	// Generating control signals //
	////////////////////////////////
	
	
	// Main Decoder //
	always_comb begin
		
		// Default values
		ctrl.opA_sel = OPA_RF;
		ctrl.opB_sel = OPB_IMM;
		ctrl.next_pc_sel = NEXTPC_PC_1;
		ctrl.branch_type = BRANCH_NONE;
	
		ctrl.mem_op = MEM_NONE;
		ctrl.mem_byte_en = 4'b1111;
		
		ctrl.rd_wdata_sel = RD_ALU;
		ctrl.rd_write_en = 1'b0;
		
		unique case (opcode)
			OPCODE_OP: begin
					ctrl.opB_sel = OPB_RF;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_OP_IMM: begin
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_LOAD: begin
					ctrl.mem_op = MEM_LOAD;
					ctrl.rd_wdata_sel = RD_MEM;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_STORE: begin
					ctrl.mem_op = MEM_STORE;
				end 
			OPCODE_BRANCH: begin
					ctrl.opB_sel = OPB_RF;
					ctrl.next_pc_sel = NEXTPC_BRANCH;
					unique case (funct3)
						7'h00: ctrl.branch_type = BRANCH_EQ;
						7'h01: ctrl.branch_type = BRANCH_NE;
						7'h04: ctrl.branch_type = BRANCH_LT;
						7'h05: ctrl.branch_type = BRANCH_GE;
						7'h06: ctrl.branch_type = BRANCH_LTU;
						7'h07: ctrl.branch_type = BRANCH_GEU;
						default: ctrl.branch_type = BRANCH_NONE;
					endcase
				end
			OPCODE_JAL: begin
					ctrl.opA_sel = OPA_PC;
					ctrl.opB_sel = OPB_IMM_4;
					ctrl.next_pc_sel = NEXTPC_PC_IMM;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_JALR: begin
					ctrl.opA_sel = OPA_PC;
					ctrl.opB_sel = OPB_IMM_4;
					ctrl.next_pc_sel = NEXTPC_RS1_IMM;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_LUI: begin
					ctrl.rd_wdata_sel = RD_IMM;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_AUIPC: begin
					ctrl.opA_sel = OPA_PC;
					ctrl.opB_sel = OPB_IMM;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_SYSTEM: begin
				// Transfer control
			end
		endcase
	end
	
	
	
	
	// ALU Control Decoder //
	always_comb begin
		//Default Value
		ctrl.alu_op = ALU_NONE;
		ctrl.mem_byte_en = '1;
		
		unique case(opcode)
			OPCODE_OP, 
			OPCODE_OP_IMM: begin
					unique case (funct3) 
						3'h0: begin
							if(funct7 == 7'h00) ctrl.alu_op = ALU_ADD;
							else ctrl.alu_op = ALU_SUB;
						end
						3'h1: ctrl.alu_op = ALU_SLL;
						3'h2: ctrl.alu_op = ALU_SLT;
						3'h3: ctrl.alu_op = ALU_SLTU;
						3'h4: ctrl.alu_op = ALU_XOR;
						3'h5: begin
							if(funct7 == 7'h20 || imm[11:5] == 7'h20) ctrl.alu_op = ALU_SRA;
							else ctrl.alu_op = ALU_SRL;
						end
						3'h6: ctrl.alu_op = ALU_OR;
						3'h7: ctrl.alu_op = ALU_AND;
						default: ctrl.alu_op = ALU_NONE;
					endcase
				end
			OPCODE_LOAD, 
			OPCODE_STORE: begin
					ctrl.alu_op = ALU_ADD;
					unique case (funct3)
						3'h0, 3'h4: ctrl.mem_byte_en = 4'b0011;   // for lb, lh, sb, sh
						3'h1, 3'h5: ctrl.mem_byte_en = 4'b1111;
						default: ctrl.mem_byte_en = '1;
					endcase
				end
			OPCODE_BRANCH: begin
				unique case (funct3)
					7'h04, 7'h05: ctrl.alu_op = ALU_SLT;
					7'h06, 7'h07: ctrl.alu_op = ALU_SLTU;
				end 
			OPCODE_JAL, 
			OPCODE_JALR, 
			OPCODE_AUIPC:  ctrl.alu_op = ALU_ADD;
			OPCODE_LUI, 
			OPCODE_SYSTEM: ctrl.alu_op = ALU_NONE;
			default:       ctrl.alu_op = ALU_NONE;
		endcase
	end
	
endmodule