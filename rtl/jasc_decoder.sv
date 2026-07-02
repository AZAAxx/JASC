module jasc_decoder 
	import jasc_pkg::*
	(
	input logic [31:0]      instr,
	output ctrl_signals_t   ctrl
	);
	
	assign ctrl.opcode = instr[6:0];
	
	logic [4:0] rs1, rs2, rd;
	logic [2:0] funct3;
	logic [6:0] funct7;
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
		ctrl.branch_type = NONE;
		
		unique case (opcode)
			OPCODE_OP: begin
					ctrl.opB_sel = RF;
					ctrl.rd_write_en = 1'b1;
				end
			OPCODE_OP_IMM: begin
					ctrl.rd_write_en = 1'b1;
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
					ctrl.next_pc_sel = BRANCH;
					unique case (funct3)
						7'h00: ctrl.branch_type = EQ;
						7'h01: ctrl.branch_type = NE;
						7'h04: ctrl.branch_type = LT;
						7'h05: ctrl.branch_type = GE;
						7'h06: ctrl.branch_type = LTU;
						7'h07: ctrl.branch_type = GEU;
						default: ctrl.branch_type = NONE;
					endcase
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
	
	
	
	
	// ALU Control Decoder //
	always_comb begin
		//Default Value
		ctrl.alu_op = NONE;
		ctrl.alu_mask = '1;
		
		unique case(opcode)
			OPCODE_OP, 
			OPCODE_OP_IMM: begin
					unique case (funct3) 
						3'h0: begin
							if(funct7 == 7'h00) ctrl.alu_op = ADD;
							else ctrl.alu_op = SUB;
						end
						3'h1: ctrl.alu_op = SLL;
						3'h2: ctrl.alu_op = SLT;
						3'h3: ctrl.alu_op = SLTU;
						3'h4: ctrl.alu_op = XOR;
						3'h5: begin
							if(funct7 == 7'h20 || imm[11:5] == 7'h20) ctrl.alu_op = SRA;
							else ctrl.alu_op = SRL;
						end
						3'h6: ctrl.alu_op = OR;
						3'h7: ctrl.alu_op = AND;
						default: ctrl.alu_op = NONE;
					endcase
				end
			OPCODE_LOAD, 
			OPCODE_STORE: begin
					ctrl.alu_op = ADD;
					unique case (funct3)
						3'h0, 3'h4: ctrl.alu_mask = 32'h00ff;
						3'h1, 3'h5: ctrl.alu_mask = 32'hffff;
						default: ctrl.alu_mask = '1;
					endcase
				end
			OPCODE_BRANCH: begin
				unique case (funct3)
					7'h04, 7'h05: ctrl.alu_op = SLT;
					7'h06, 7'h07: ctrl.alu_op = SLTU;
				end 
			OPCODE_JAL, 
			OPCODE_JALR, 
			OPCODE_AUIPC:  ctrl.alu_op = ADD;
			OPCODE_LUI, 
			OPCODE_SYSTEM: ctrl.alu_op = NONE;
			default:       ctrl.alu_op = NONE;
		endcase
	end
	
endmodule