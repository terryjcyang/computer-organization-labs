// File I write/change
`timescale 1ns/1ps
`include "ALU_1bit.v"
module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	output 		   [32-1:0]	result,        // 32 bits result            (output)
	output 			        zero,          // 1 bit when the output is 0, zero must be set (output)
	output 			        cout,          // 1 bit carry out           (output)
	output 		            overflow       // 1 bit overflow            (output)
	);

/* Write down your code HERE */

	wire [30:0] carry;						// carry out for each ALU
	// Convention to declare most wires in the module at beginning
	wire cout_msb_raw, set, set_raw, n_b31, xor1, computed_overflow, is_arith;

	wire Ainvert, Binvert;
	// buf(Ainvert, ALU_control[3]);			// equivalent to:(at dataflow level) assign Ainvert = ...
	// buf(Binvert, ALU_control[2]);
	
	ALU_1bit ALU0(.src1(src1[0]),
				.src2(src2[0]),
				.less(set),					// MSB result(further concern overflow) -> slt's rd
				.Ainvert(ALU_control[3]),
				.Binvert(ALU_control[2]),
				.cin(ALU_control[2]),		// cin = Binvert
				.operation(ALU_control[1:0]),
				.result(result[0]),
				.cout(carry[0]));

	// Iteratively generate modules
	genvar i;
	generate
		for(i = 1; i <= 30; i = i + 1) begin
		ALU_1bit ALUi(.src1(src1[i]),
					.src2(src2[i]),
					.less(1'b0),			// 1-bit binary 0
					.Ainvert(ALU_control[3]),
					.Binvert(ALU_control[2]),
					.cin(carry[i - 1]),
					.operation(ALU_control[1:0]),
					.result(result[i]),
					.cout(carry[i]));
		end
	endgenerate

	ALU_1bit ALU31(.src1(src1[31]),
				.src2(src2[31]),
				.less(1'b0),				// 
				.Ainvert(ALU_control[3]),
				.Binvert(ALU_control[2]),
				.cin(carry[30]),
				.operation(ALU_control[1:0]),
				.result(result[31]),
				.cout(cout_msb_raw));			// 
    
	xor(computed_overflow, carry[30], cout_msb_raw);

	// * In here, compute 'set' and 'cout' outside ALU31
	// Set signal for slt
	/* 	1. Assign set_raw = src1[31] ^ ~src2[31] ^ carry[30];
		(Compute result of adder_31)
		2. Consider if overflow, set is inverse of set_raw
	*/
	not(n_b31, src2[31]);					// b_inverted
	xor(xor1, carry[30], src1[31]);
	xor(set_raw, xor1, n_b31);
	xor(set, set_raw, computed_overflow);

	// zero
	Nor_32bit All0_checker(.src(result),
							.result(zero));
		// Equivalent: 
		//assign zero = ~|result;	// reduction nor
    
    // Enable arithmetic flags(overflow & cout) only for ADD/SUB
	// For logical operations, force cout and overflow to 0
	// 		Purpose: deterministic behavior, easy to verify
	wire n2;
	not(n2, ALU_control[0]);
	and(is_arith, ALU_control[1], n2);
		// Equivalent:
		// assign is_arith = (ALU_control[1:0] == 2'b10);

	and(cout, cout_msb_raw, is_arith);
	and(overflow, computed_overflow, is_arith);
		// Equivalent:
		// assign overflow = is_arith ? computed_overflow : 1'b0;
		// assign cout = is_arith ? cout_msb_raw : 1'b0;
	
endmodule

module Nor_32bit(
	input [31:0] src,
	output result
	);

	wire [30:0] nor_levels;					// OR tree
	not(result, nor_levels[0]);
	genvar i;
	generate
		for(i = 0; i <= 14; i = i + 1) begin
			or(nor_levels[i], nor_levels[2*i + 1], nor_levels[2*i + 2]);
		end
		for(i = 15; i <= 30; i = i + 1) begin
			or(nor_levels[i], src[2*(i-15)], src[2*(i-15) + 1]);
		end
	endgenerate

endmodule