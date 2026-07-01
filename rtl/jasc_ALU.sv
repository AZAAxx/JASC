module jasc_ALU 
	import jasc_pkg::*;
	(
	input logic [31:0]   oA,
	input logic [31:0]   opB,
	input alu_op_e       alu_op,
	
	output logic [31:0] result,
	output logic        flag_z,
	output logic        flag_n
	);
	
	always_comb begin
		unique_case (alu_op)
			ADD: result = opA + opB;
			SUB: result = opA - opB;
			AND: result = opA & opB;
			OR: result = opA | opB;
			XOR: result = opA ^ opB;
			
			default: result = 'x;
		endcase
	end
	
	always_comb begin
		flag_z = (result == '0);
		flag_n = (result <  '0);
	end
	
endmodule