module jasc_ALU 
	import jasc_pkg::*;
	(
	input logic [31:0]   a,
	input logic [31:0]   b,
	input alu_op_e       alu_op,
	
	output logic [31:0] result,
	output logic        flag_z,
	output logic        flag_n
	);
	
	always_comb begin
		result = '0; // default value
		
		unique case (alu_op)
			ADD:  result = a + b;
			SUB:  result = a - b;
			AND:  result = a & b;
			OR:   result =  a | b;
			XOR:  result = a ^ b;
			SLL:  result = a << b[4:0];
			SRL:  result = a >> b[4:0];
			SRA:  result = signed'(a) >>> b[4:0];
			SLT:  result = (signed'(a) < signed'(b)) ? 1'b1 : 1'b0;
			SLTU: result = (a < b) ? 1'b1 : 1'b0;
			default: result = 'x;
		endcase
	end
	
	always_comb begin
		flag_z = (result == '0);
		flag_n = (result <  '0);
	end
	
endmodule