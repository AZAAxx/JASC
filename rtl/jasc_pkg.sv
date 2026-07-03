package jasc_pkg;

	typedef enum logic [6:0] {
		OPCODE_LOAD     = 7'h03, 
		OPCODE_OP_IMM   = 7'h13, 
		OPCODE_AUIPC    = 7'h17, 
		OPCODE_STORE    = 7'h23, 
		OPCODE_OP       = 7'h33, 
		OPCODE_LUI      = 7'h37, 
		OPCODE_BRANCH   = 7'h63, 
		OPCODE_JALR     = 7'h67, 
		OPCODE_JAL      = 7'h6f, 
		OPCODE_SYSTEM   = 7'h73 
	} opcode_e;
	
	
	
	
	/////////////////////////////////
	// Instruction Control Signals //
	/////////////////////////////////
		
		
	// ALU Operand select MUX Enums
	typedef enum logic [1:0] { OPA_RF, OPA_IMM, OPA_PC} opA_sel_e;
	typedef enum logic [1:0] { OPB_RF, OPB_IMM, OPB_IMM_4 } opB_sel_e;
	
	typedef enum logic [3:0] {
		ALU_NONE,
		ALU_ADD,
		ALU_SUB, 
		ALU_AND,
		ALU_OR,
		ALU_XOR,
		ALU_SLL,
		ALU_SRL,
		ALU_SRA,
		ALU_SLT,
		ALU_SLTU
	} alu_op_e;
	
	// Next PC MUX Enum
	typedef enum logic [1:0] {
		NEXTPC_BRANCH                      // PC = PC + IMM     IF alu_res = 1   (enables branches)
		NEXTPC_PC_1,                       // PC = PC + 1
		NEXTPC_PC_IMM,                     // PC = PC + IMM
		NEXTPC_RS1_IMM                     // PC = RS1 = IMM
	} next_pc_sel_e;
	
	// Comparators for branch operations
	typedef enum logic [2:0] {
		BRANCH_NONE,
		BRANCH_EQ,
		BRANCH_NE,
		BRANCH_LT,
		BRANCH_GE,
		BRANCH_LTU,
		BRANCH_GEU
	} branch_type_e;
	
	// Mem Operation Enum
	typedef enum logic [1:0] { MEM_NONE, MEM_LOAD, MEM_STORE } mem_op_e;
	
	// Regfile WB  MUX Enum
	typedef enum logic [1:0] { RD_ALU, RD_MEM, RD_IMM } rd_wdata_sel_e;
	
	
	

	
	
	typedef struct packed {
		opA_sel_e      opA_sel;      // Execute
		opB_sel_e      opB_sel;
		alu_op_e       alu_op;
		next_pc_sel_e  next_pc_sel;
		branch_type_e  branch_type;
		mem_op_e       mem_op;       // Memory
		rd_wdata_sel_e rd_wdata_sel; // Writeback
		logic          rd_write_en;
	} ctrl_signals_t;
	
	
	// Later to be used for RVFI
	typedef struct packed {
		logic [31:0]  instr;
		logic [31:0]  pc_rdata;
		logic [31:0]  pc_wdata;
		logic [4:0]   rs1_addr;
		logic [4:0]   rs2_addr;
		logic [4:0]   rd_addr;
		logic [31:0]  rs1_rdata;
		logic [31:0]  rs2_rdata;
		logic [31:0]  rd_wdata;
		logic [31:0]  mem_addr;
		logic [3:0]   mem_rmask;
		logic [3:0]   mem_wmask;
		logic [31:0]  mem_rdata;
		logic [31:0]  mem_wdata;
		logic         trap;
	} instr_info_t;
	
	
	
	
	
	////////////////////////
	// Pipeline Registers //
	////////////////////////

	typedef struct packed {
		logic          valid;
		logic [31:0]   instr;
		logic [31:0]   pc;
	} if_id_t;
	
	
	typedef struct packed {
		logic          valid;
		ctrl_signals_t ctrl;
		instr_info_t   info;
		logic [31:0]   imm;
	} id_ex_t;

	
	typedef struct packed {
		logic          valid;
		ctrl_signals_t ctrl;
		instr_info_t   info;
		logic [31:0]   alu_res;
		logic          flag_z;
		logic          flag_n;
	} ex_mem_t;

	
	typedef struct packed {
		logic          valid;
		ctrl_signals_t ctrl;
		instr_info_t   info;
		logic [31:0]   alu_res;
		logic [31:0]   mem_rdata;
	} mem_wb_t;
	
	
	
	
	//////////////////////////////
	// Pipeline Control Signals //
	//////////////////////////////
	
	
	typedef struct packed {

	} pipeline_ctrl_signals_t;
	
	
endpackage
	
	
	

//////////////////////
// Memory Interface //
//////////////////////

// Write these later
// They share the same physical memory but different interfaces
instruction_if imem_bus;
memory_if      dmem_bus;
	
	