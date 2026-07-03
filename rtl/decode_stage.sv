module decode_stage import jasc_pkg::*
	(
		input if_id_t          if_id;
		output id_ex_t         id_ex;
		
		//Register File interface
		output logic [4:0]     rs1_addr,
		output logic [4:0]     rs2_addr,
		input  logic [31:0]    rs1_rdata,
		input  logic [31:0]    rs2_rdata,
		
	);
	
	
	// Implemented signals
	ctrl_signals_t ctrl;
	logic [4:0]  rs1_addr, rs2_addr, rd_addr;
	logic [31:0] rs1_rdata, rs2_rdata;
	logic [31:0] imm;
	
	
	/////////////
	// DECODER //
	/////////////

	// Drives the register file by producing the register address values
	jasc_decoder decoder (
		.instr         (if_id.instr), 
		
		.ctrl          (ctrl),
		.rs1           (rs1_addr),
		.rs2           (rs2_addr),
		.rd            (rd_addr),
		.imm           (imm)
	);
	
	
	// assign the input signals and produced signals to the output packet
	always_comb begin
		id_ex = '0;          // clear the output packet
		
		id_ex.valid          = if_id.valid;
		id_ex.ctrl           = ctrl;
		
		id_ex.info.instr     = if_id.instr;
		id_ex.info.pc_rdata  = if_id.pc;
		
		id_ex.info.rs1_addr  = rs1_addr;
		id_ex.info.rs2_addr  = rs2_addr;
		id_ex.info.rd_addr   = rd_addr;
		
		id_ex.info.rs1_rdata = rs1_rdata;
		id_ex.info.rs2_rdata = rs2_rdata;

		id_ex.imm            = imm;
	end
	
	
endmodule