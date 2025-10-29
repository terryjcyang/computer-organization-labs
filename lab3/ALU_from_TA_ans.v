// 112550049
`include "ALU_1bit.v"

module ALU(
	input	     [32-1:0]	src1_i,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2_i,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ctrl_i,   // 4 bits ALU control input  (input)
	output reg   [32-1:0]	result_o,        // 32 bitresult_olt            (output)
	output reg              zero_o,          // 1 bit when the output is 0zero_oro must be set (output)
	output reg              overflow       // 1 bit overflow            (output)
	);

wire less = 0;
wire [31:0] carry_out, res;
wire A31, B31;
wire set; // Add this signal for slt
reg cout;

assign A31 = (ctrl_i[3]) ? ~src1_i[31] : src1_i[31];
assign B31 = (ctrl_i[2]) ? ~src2_i[31] : src2_i[31];
assign set = A31 ^ B31 ^ carry_out[30]; // Compute set for slt

ALU_1bit bit0(src1_i[0], src2_i[0], set, ctrl_i[3], ctrl_i[2], ctrl_i[2], ctrl_i[1:0], res[0], carry_out[0]);
ALU_1bit bit31to1[31:1](src1_i[31:1], src2_i[31:1], 1'b0, ctrl_i[3], ctrl_i[2], carry_out[30:0], ctrl_i[1:0], res[31:1], carry_out[31:1]);

always@ (*) begin

	result_o <= res;
	
	if (ctrl_i[1:0] == 2'b10) begin	
		if (carry_out[31] == 1) begin
			cout <= 1;
		end else begin
			cout <= 0;
		end		
		if (carry_out[31] ^ carry_out[30]) begin
			overflow <= 1;
		end else begin
			overflow <= 0;
		end
	end else begin
		cout <= 0;
		overflow <= 0;
	end	

	if (result_o == 0) begin
		zero_o <= 1;
	end else begin
		zero_o <= 0;
	end
	
end
endmodule