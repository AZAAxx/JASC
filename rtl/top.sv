module top ();
	JASC core(
			.clk(clk),
			.rst_n(rst_n),
			.imem(),
			.dmem());
			
	mem_unit memory();
	
	
	
endmodule