// File I write/change
module Decoder( 
	instr_op_i,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	BranchType_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
);

// I/O ports
input	[6-1:0] instr_op_i;

output	[2-1:0] ALU_op_o, RegDst_o, MemtoReg_o, Jump_o;		// Turn Jump_o to 2 bits(for jr)
// WHY BUS?
// output  [2-1:0] Branch_o;
output 		Branch_o, BranchType_o;
output		ALUSrc_o, RegWrite_o, MemRead_o, MemWrite_o;

// Internal Signals
reg			r_format, jr, lw, sw, branch, branchType;
reg [1:0]	ALU_op, RegDst, Jump, MemtoReg;
	// jump is for (0, 1, 2) <- (original, j, jr)
	// MemtoReg is for (0, 1, 2) <- (r-format, lw, jal)

// Main function

always@(*)begin
	// Ref. to slide p54
	{r_format, lw, sw, branch, Jump} = 6'b000000;
	case (instr_op_i)
		0: r_format = 1;
		43: lw = 1;
		35: sw = 1;
		4: branch = 1;
		3: Jump = 1;	// j
		default:;
	endcase

	// Ref. to ch4 slide p43
	if(r_format)
		ALU_op = 2;
	else if(lw | sw)
		ALU_op = 0;
	else // branch
		ALU_op = 1;

	if(jr)
		RegDst = 2;
	else if(r_format)
		RegDst = 1;
	else
		RegDst = 0;

	branchType = (instr_op_i == 6'b000100) ? 1 : 0; // BEQ

	if(lw)
		MemtoReg = 1;
	else if(jr)
		MemtoReg = 2;
	else
		MemtoReg = 0;

	// if(instr_op_i == 8) Jump = 2;	// jr
	
end

assign ALU_op_o = ALU_op;
assign RegDst_o = RegDst;
assign MemtoReg_o = MemtoReg;
assign Branch_o = branch;
assign BranchType_o = branchType;
assign ALUSrc_o = lw | sw;
assign RegWrite_o = r_format | lw;
assign Jump_o = Jump;
assign MemRead_o = lw;
assign MemWrite_o = sw;

endmodule


