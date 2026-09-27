module jasc_ALU import jasc_pkg::*;
	(
		input logic [31:0]   a,
		input logic [31:0]   b,
		input alu_op_e       alu_op,
		
		output logic [31:0] result,
		output logic        flag_z,
		output logic        flag_n
	);
	
	always_comb begin
		result = 32'b0; // default value
		
		unique case (alu_op)
			ALU_NONE: result = 32'b0; // default value
			ALU_ADD:  result = a + b;
			ALU_SUB:  result = a - b;
			ALU_AND:  result = a & b;
			ALU_OR:   result =  a | b;
			ALU_XOR:  result = a ^ b;
			ALU_SLL:  result = a << b[4:0];
			ALU_SRL:  result = a >> b[4:0];
			ALU_SRA:  result = signed'(a) >>> b[4:0];
			ALU_SLT:  result = (signed'(a) < signed'(b)) ? 1'b1 : 1'b0;
			ALU_SLTU: result = (a < b) ? 1'b1 : 1'b0;
			default: $error("Invalid ALU operation: %0d", alu_op);
		endcase
	end
	
	always_comb begin
		flag_z = (result == '0);
		flag_n = result[31];
	end
	
endmodule