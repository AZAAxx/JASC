module JASC (
	input logic       clk,
	input logic       rst_n,
	mem_if.master     imem,
	mem_if.master     dmem
	);
	
	// Pipeline register structs
	if_id_t           if_id_o;
	id_ex_t           id_ex_o;
	ex_mem_t          ex_mem_o;
	mem_wb_t          mem_wb_o;
	
	if_id_t           if_id_i;
	id_ex_t           id_ex_i;
	ex_mem_t          ex_mem_i;
	mem_wb_t          mem_wb_i;
	
	
	//IMEM and DMEM interface
	imem_req_t        imem_req;
	imem_rsp_t        imem_rsp;
	
  	dmem_req_t        dmem_req;
	dmem_rsp_t        dmem_rsp;
	
	
	//register file interface
	logic [4:0]     rs1_addr;
	logic [4:0]     rs2_addr;
	logic [31:0]    rs1_rdata;
	logic [31:0]    rs2_rdata;
	
	logic [4:0]     rd_addr;
	logic [31:0]    rd_wdata;
	logic           rd_write_en;
	
	
	
	////////
	// PC //
	////////
	
	logic [31:0] pc;
	logic [31:0] next_pc;
	always_ff(posedge clk, negedge rst_n) begin
		if(!rst_n) pc <= '0;
		else pc <= next_pc;
	end
	
	
	
	////////////
	// Stages //
	////////////
	
	fetch_stage s1 (
			// pipeline interface
			.if_id(if_id_o),
			
			.pc(pc),
			
			// IMEM interface
			.imem_req(imem_req),
			.imem_rsp(imem_rsp)
	);
	
	decode_stage s2 (
			// pipeline interface
			.if_id(if_id_i),
			.id_ex(id_ex_o), 
			
			// Register file interface
			.rs1_addr(rs1_addr),
			.rs2_addr(rs2_addr),
			.rs1_rdata(rs1_rdata),
			.rs2_rdata(rs2_rdata)
	);
	
	execute_stage s3 (
			// pipeline interface
			.id_ex(id_ex_i), 
			.ex_mem(ex_mem_o),
			
			.next_pc(next_pc),
	);
	
	memory_stage s4 (
			.ex_mem(ex_mem_i), 
			.mem_wb(mem_wb_o),
			
			// DMEM interface
			.dmem_req(dmem_req),
			.dmem_rsp(dmem_rsp)
	);
	
	writeback_stage s5 (
			.mem_wb(mem_wb_i),
			
			// Register file interface
			.rd_addr(rd_addr),
			.rd_wdata(rd_wdata),
			.rd_write_en(rd_write_en)
	);
	 
	// Interface registers 
	always_ff(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			if_id_i <= '0;
			id_ex_i <= '0;
			ex_mem_i <= '0;
			mem_wb_i <= '0;
		else begin
			if_id_i <= if_id_o;
			id_ex_i <= id_ex_o;
			ex_mem_i <= ex_mem_o;
			mem_wb_i <= mem_wb_o;
		end
	end
	 
	 
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