module JASC (
	input logic clk,
	input logic rst_n,
	
	// Instruction memory interface  -- from ibex!
	output logic                         instr_req_o,
	output logic [31:0]                  instr_addr_o,
	
	input  logic                         instr_gnt_i,
	input  logic                         instr_rvalid_i,
	input  logic [31:0]                  instr_rdata_i,
	input  logic                         instr_err_i,

	// Data memory interface   -- from ibex!
	output logic                         data_req_o,
	output logic                         data_we_o,
	output logic [3:0]                   data_be_o,   // what is this?
	output logic [31:0]                  data_addr_o,
	output logic [31:0]                  data_wdata_o,
	
	input  logic                         data_gnt_i,
	input  logic                         data_rvalid_i,
	input  logic [31:0]                  data_rdata_i,
	input  logic                         data_err_i,
	
	// Interrupt inputs
	input logic                          irq_software_i,
	input logic                          irq_hardware_i,
	input logic                          irq_exception_i,

	// RISC-V Formal Interface
	//....
	);
	
	// PC update part needs its own adder
	
	
endmodule