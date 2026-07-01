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
	
	
	
	//////////////////////////////
	// Pipeline Control Signals //
	//////////////////////////////
	
	
	typedef struct packed {

	} pipeline_ctrl_signals_t;
	
	
	
	
	
	
	
	/////////////////////////////////
	// Instruction Control Signals //
	/////////////////////////////////
		
		
	// ALU Operand select MUX Enums
	typedef enum logic [1:0] {
		RF,
		IMM,
		PC
	} opA_sel_e;
	
	typedef enum logic [1:0] {
		RF,
		IMM,
		IMM_4    // immediate = 4
	} opB_sel_e;
	
	typedef enum logic [3:0] {
		NONE,
		ADD,
		SUB, 
		AND,
		OR,
		XOR,
		SLL,
		SRL,
		SRA,
		SLT,
		SLTU
	} alu_op_e;
	
	
	// Mem Operation Enum
	typedef enum logic [2:0] {
		NONE,
		LOAD,
		STORE
	} mem_op_e;
	
	
	// Next PC MUX Enum
	typedef enum logic [1:0] {
		PC_1,                       // PC = PC + 1
		PC_IMM,                     // PC = PC + IMM
		RS1_IMM                     // PC = RS1 = IMM
	} next_pc_sel_e;

	
	// Regfile WB  MUX Enum
	typedef enum logic [1:0] {
		ALU,
		MEM,
		IMM
	} rd_wdata_sel_e;
	
	
	
	typedef struct packed {
		// RegFile controls (Decode)
		logic [4:0]    rs1_sel;
		logic [4:0]    rs2_sel;
		
		// ALU controls (Execute)
		opA_sel_e      opA_sel;
		opB_sel_e      opB_sel;
		alu_op_e       alu_op;
		logic [31:0]   alu_mask;
		
		// Memory controls (Memory)
		mem_op_e       mem_op;
		logic [31:0]   mem_addr_sel;
		logic [31:0]   mem_wdata_sel;
		
		// Writeback controls (WB)
		next_pc_sel_e  next_pc_sel;
		logic [4:0]    rd_sel;
		rd_wdata_sel_e rd_wdata_sel;
		logic          rd_write_en;
	} ctrl_signals_t;
	
	
	
	
	

	////////////////////////
	// Pipeline Registers //
	////////////////////////

	typedef struct packed {
		logic        valid;
		
		// Data
		logic [31:0] pc;
		logic [31:0] instr;
		//logic        compressed;
		//logic [31:0] instr2;
	} fetch_packet_t;
	
	
	
	
	
	typedef struct packed {
		logic        valid;
		
		// Instruction Data
		logic [31:0] pc;
		logic [31:0] instr;
		//opcode_e     opcode;
		logic [4:0]  rs1;
		logic [4:0]  rs2;
		logic [4:0]  rd;
		//logic [2:0]  funct3;
		//logic [6:0]  funct7;
		logic [31:0] imm;
		
		// RegFile read values
		logic [31:0] rs1_data;
		logic [31:0] rs2_data;
		
		// Control Signals
		ctrl_signals_t control;
		
	} decode_packet_t;

	
	
	typedef struct packed {
		logic        valid;
		
		//Data
		logic [31:0] pc;
		logic [31:0] instr;
		logic [4:0]  rd;
		
		//ALU results
		logic [31:0] alu_res;
		logic        flag_z;
		logic        flag_n;
		
		// Control signals
		ctrl_signals_t control;
	} execute_packet_t;

	
	
	
	typedef struct packed {
		logic valid;
		
		//Data
		logic [31:0] pc;
		logic [31:0] instr;
		logic [4:0]  rd;
		
		// Memory results
		logic [31:0] mem_rdata;
		
		// Control signals
		ctrl_signals_t control;
	} memory_packet_t;
	
	
	
	typedef struct packed {
		logic valid;
		
		//Data
		logic [31:0] pc;
		logic [31:0] instr;
		logic [4:0]  rd;
		
		// Control Signals
		ctrl_signals_t control;
	} commit_packet_t;

	
	
	typedef struct packed {
	
	} rvfi_retire_info_t;
	
	
endpackage
	
	
	
	
	
	//////////////////////
	// Memory Interface //
	//////////////////////
	
	interface memory_if (input logic clk, input logic rst_n);
		logic [31:0] mem_addr;
		logic [31:0] mem_rdata;
		logic [31:0] mem_wdata;
		logic        mem_write_en;
		logic        mem_read_en;
	
		modport Memory (
			input clk, rst_n, mem_addr, mem_wdata, mem_write_en, mem_read_en;
			output mem_rdata;
		);
			
		modport Core (
			input clk, rst_n, mem_rdata;
			ouptput mem_addr, mem_wdata, mem_write_en, mem_read_en;
		);
	endinterface
	
	
	
	
	/////////////////////////////
	// Register File Interface //
	/////////////////////////////
	
	interface register_file_if (input logic clk, input logic rst_n);
		logic [4:0]  regA,
		logic [4:0]  regB,
		logic [31:0] regA_rdata,
		logic [31:0] regB_rdata,
		
		logic [4:0]  regW,
		logic [31:0] regW_wdata
		logic        write_e,
		);
		
		modport RegFile (
			input clk, rst_n, regA, regB, regW, write_e, regW_wdata;
			output regA_rdata, regB_rdata;
		);
		
		modport Core (
			input clk, rst_n, regA_rdata, regB_rdata;
			output regA, regB, regW, write_e, regW_wdata;
		);
	endinterface
	