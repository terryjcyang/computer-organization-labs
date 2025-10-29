// File I write/change
`timescale 1ns/1ps
`include "MUX_2to1.v"
`include "MUX_4to1.v"

module ALU_1bit(
	input				src1,       //1 bit source 1  (input)
	input				src2,       //1 bit source 2  (input)
	input				less,       //1 bit less      (input)
	input 				Ainvert,    //1 bit A_invert  (input)
	input				Binvert,    //1 bit B_invert  (input)
	input 				cin,        //1 bit carry in  (input)
	input 	    [2-1:0] operation,  //2 bit operation (input)
	output wire         result,     //1 bit result    (output)
	output wire         cout        //1 bit carry out (output)
	);
		
/* Write down your code HERE */

	// level 1
	wire n_a, n_b, M_ain_out, M_bin_out;
	not(n_a, src1);
	not(n_b, src2);
	MUX_2to1 M_ain(.src1(src1), 
					.src2(n_a), 
					.select(Ainvert),
					.result(M_ain_out));
	MUX_2to1 M_bin(.src1(src2), 
					.src2(n_b), 
					.select(Binvert),
					.result(M_bin_out));

	// level 2
	wire a1, o1, add1;
	and(a1, M_ain_out, M_bin_out);
	or(o1, M_ain_out, M_bin_out);
	Full_Adder FA(.src1(M_ain_out),
				.src2(M_bin_out),
				.cin(cin),
				.sum(add1),
				.cout(cout));

	// level 3
	MUX_4to1 M_res(.src1(a1),
					.src2(o1),
					.src3(add1),
					.src4(less),
					.select(operation[1:0]),		// bus I/O port
					.result(result));

endmodule



module Full_Adder(
	input	src1,
	input	src2,
	input	cin,
	output	sum,
	output	cout
	);

	wire xor1, a1, a2;
	
	// level 1
	xor(xor1, src1, src2);
	and(a1, src1, src2);

	// level 2
	xor(sum, xor1, cin);
	and(a2, xor1, cin);
	
	// level 3
	or(cout, a2, a1);

endmodule
