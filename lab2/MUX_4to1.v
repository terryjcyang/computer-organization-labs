// File I write/change
`timescale 1ns/1ps

module MUX_4to1(
	input			src1,
	input			src2,
	input			src3,
	input			src4,
	input   [2-1:0] select,
	output 			result
	);

/* Write down your code HERE */
	wire M0_out, M1_out;

	// level 1
	MUX_2to1 M0(.src1(src1), 
				.src2(src2), 
				.select(select[0]),	// use bus // s[1] is MSB
				.result(M0_out));

	MUX_2to1 M1(.src1(src3), 
				.src2(src4), 
				.select(select[0]),
				.result(M1_out));
	
	// level 2
	MUX_2to1 M2(.src1(M0_out), 
				.src2(M1_out), 
				.select(select[1]),
				.result(result));

endmodule

