// 112550049
`ifndef ALU_V
`define ALU_V

`include "ALU_1bit.v"

module ALU(
	src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o,
	overflow
	);
     
// I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output reg [32-1:0]	 	result_o;
output reg		       	zero_o;
output reg  			overflow;

// Internal signals
wire Ainvert, Binvert;
wire [1:0] ALU_operation;
wire [31:0] carry_out, res;
wire A31, B31, set;		// set is used by slt

assign Ainvert = ctrl_i[3];
assign Binvert = ctrl_i[2];
assign ALU_operation = ctrl_i[1:0];

ALU_1bit ALU0(.src1(src1_i[0]),
			.src2(src2_i[0]),
			.less(set),					// MSB result(further concern overflow) -> slt's rd
			.Ainvert(Ainvert),
			.Binvert(Binvert),
			.cin(Binvert),
			.operation(ALU_operation),
			.result(res[0]),
			.cout(carry_out[0]));

ALU_1bit ALU31to1[31:1](.src1(src1_i[31:1]),
						.src2(src2_i[31:1]),
						.less(1'b0),			// 1-bit binary 0
						.Ainvert(Ainvert),
						.Binvert(Binvert),
						.cin(carry_out[30:0]),
						.operation(ALU_operation),
						.result(res[31:1]),	// store result in wire temporarily
						.cout(carry_out[31:1]));

// Main function
assign A31 = (Ainvert) ? ~src1_i[31] : src1_i[31];
assign B31 = (Binvert) ? ~src2_i[31] : src2_i[31];
assign set = (A31 ^ B31 ^ carry_out[30]);

// Use always to leverage statements like if...else..., case(), ...
always @(*) begin
	result_o = res;

	if(ALU_operation == 2'b10)
		overflow = (carry_out[31] ^ carry_out[30]);
	else
		overflow = 0;

	zero_o = (result_o == 0);
end

endmodule

`endif
