module top (input logic clk, input logic rst_n);
	JASC core(
			.clk(clk),
			.rst_n(rst_n),
			.imem(),
			.dmem());
			
	mem_unit instr_mem();
	
	mem_unit data_mem();
	
endmodule