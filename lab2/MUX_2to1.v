// 112550049
`timescale 1ns/1ps

module MUX_2to1(
	input	src1,
	input   src2,
	input	select,
	output	result
	);

/* Write down your code HERE */
	// select = 0 -> src1
	wire n1, a1, a2;

	not(n1, select);
	and(a1, src1, n1);
	and(a2, src2, select);
	or(result, a1, a2);

endmodule

