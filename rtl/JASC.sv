module JASC (
	input logic       clk,
	input logic       rst_n,
	memory_if.core    mem_bus
	);
	
	if_id_t           if_id;
	id_ex_t           id_ex;
	ex_mem_t          ex_mem;
	mem_wb_t          mem_wb;
	
	
	//register file interface
	logic [4:0]     rs1_addr,
	logic [4:0]     rs2_addr,
	logic [31:0]    rs1_rdata,
	logic [31:0]    rs2_rdata,
	
	logic [4:0]     rd_addr,
	logic [31:0]    rd_wdata;
	logic           rd_write_en;
	
	
	
	
	
	fetch_stage s1 (
			.if_id(if_id)  
	);
	
	decode_stage s2 (
			.if_id(if_id)  ,
			.id_ex(id_ex)  , 
			
			// Register file interface
			.rs1_addr(rs1_addr),
			.rs2_addr(rs2_addr),
			.rs1_rdata(rs1_rdata),
			.rs2_rdata(rs2_rdata)
	);
	
	execute_stage s3 (
			.id_ex(id_ex), 
			.ex_mem(ex_mem)
	);
	
	memory_stage s4 (
			.ex_mem(ex_mem), 
			.mem_wb(mem_wb),
			
			// Memory interface
	);
	
	writeback_stage s5 (
			.mem_wb(mem_wb),
			
			// Register file interface
			.rd_addr(rd_addr),
			.rd_wdata(rd_wdata),
			.rd_write_en(rd_write_en)
	);
	 
	 
	 
	///////////////////
	// REGISTER FILE //
	///////////////////
	
	jasc_register_file RegFile (
		.clk           (clk),
		.rst_n         (rst_n),
		.rs1           (rs1_addr),
		.rs2           (rs2_addr),
		.rd            (rd_addr),
		.rd_wdata      (rd_wdata),
		.rd_write_en   (rd_write_en),
		
		.rs1_rdata     (rs1_rdata),
		.rs2_rdata     (rs2_rdata)
	);
	
	
endmodule