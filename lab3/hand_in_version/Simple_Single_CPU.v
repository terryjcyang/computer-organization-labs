// 112550049
`include "ProgramCounter.v"
`include "Instr_Memory.v"
`include "Reg_File.v"
`include "Data_Memory.v"

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Decoder.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"   // for jal, write register
`include "Shift_Left_Two_32.v"
`include "Shifter.v"
`include "Sign_Extend.v"

module Simple_Single_CPU(
        clk_i,
	rst_i
);

/*
I/O port
*/
input         clk_i;
input         rst_i;

/*
Internal Signals
(declared in the stage where they are produced)
*/
// IF
wire [31:0]     instr_addr, pc_plus_4;
wire [31:0]     instruction;
// ID & RegRead
wire [1:0]      ALU_op, RegDst, Jump, MemtoReg;
wire	        ALUSrc, RegWrite, Branch, BranchType, MemRead, MemWrite;
wire [4:0]      write_register;
wire [31:0]     RSdata, RTdata;
wire [31:0]     extended_imm;
// EX
wire [31:0]     branch_relative_addr, branch_addr;
wire [31:0]     ALU_data2;
wire [31:0]     ALU_result;
wire            zero, overflow;
wire [31:0]     shifter_result;
wire [4:0]      shamtSrc_for_shifter;
wire [4-1:0]    ALU_Ctrl;               // ALU_operation
wire            isShiftLeft, shamtIsRs, isShiftInstr;
wire            jr;
// MEM
wire            data_can_branch;
wire [31:0]     MemSrc_addr, Mem_result;
//WB
wire [31:0]     pc_addr_after_whether_branch, pc_src;
wire [31:0]     write_data;

/*
Components
(primarily, the upper ones in the architecture figure is placed eariler.)
*/

// IF
ProgramCounter PC(
        .clk_i(clk_i),      
        .rst_i(rst_i),     
        .pc_in_i(pc_src),   
        .pc_out_o(instr_addr) 
);

Adder Add_for_PC(
        .src1_i(instr_addr),
        .src2_i(32'd4),
        .sum_o(pc_plus_4)
);

Instr_Memory IM(
        .pc_addr_i(instr_addr),  
        .instr_o(instruction)    
);

// ID & RegRead
Decoder Control(
        .instr_op_i(instruction[31:26]),
	.ALU_op_o(ALU_op),
	.ALUSrc_o(ALUSrc),
	.RegWrite_o(RegWrite),
	.RegDst_o(RegDst),
	.Branch_o(Branch),
        .BranchType_o(BranchType),
	.Jump_o(Jump),
	.MemRead_o(MemRead),
	.MemWrite_o(MemWrite),
	.MemtoReg_o(MemtoReg)
);

MUX_3to1 #(.size(5)) Mux_write_reg(
        .data0_i(instruction[25:21]),   // rs
        .data1_i(instruction[20:16]),   // rt
        .data2_i(5'd31),                   // $ra(for jal) = $31
        .select_i(RegDst),
        .data_o(write_register)
);

Reg_File Registers(
        .clk_i(clk_i),
        .rst_i(rst_i) ,     
        .RSaddr_i(instruction[25:21]),  // rs
        .RTaddr_i(instruction[20:16]),  // rt
        .RDaddr_i(write_register), 
        .RDdata_i(write_data),
        .RegWrite_i(RegWrite),
        .RSdata_o(RSdata),  
        .RTdata_o(RTdata) 
);

Sign_Extend Sign_Extender(
        .data_i(instruction[15:0]),
        .data_o(extended_imm)
);

// EX
Shift_Left_Two_32 sll_2_for_branch(
        .data_i(extended_imm),
        .data_o(branch_relative_addr)
);

Adder Add_for_branch(
        .src1_i(pc_plus_4),
        .src2_i(branch_relative_addr),
        .sum_o(branch_addr)
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata),
        .data1_i(extended_imm),
        .select_i(ALUSrc),
        .data_o(ALU_data2)
);

ALU ALU(
        .src1_i(RSdata),
	.src2_i(ALU_data2),
	.ctrl_i(ALU_Ctrl),
	.result_o(ALU_result),
	.zero_o(zero),
	.overflow(overflow)
);

Shifter Shifter(
        .data_i(ALU_data2),
        .shamt(shamtSrc_for_shifter),
        .isShiftLeft_i(isShiftLeft),
        .data_o(shifter_result)
);

MUX_2to1 #(.size(5)) Mux_shiftAmount_for_shifter(
        .data0_i(instruction[10:6]),    // shamt
        .data1_i(RSdata[4:0]),          // for instr. sllv and srlv
        .select_i(shamtIsRs),
        .data_o(shamtSrc_for_shifter)
);

ALU_Ctrl ALU_Control(
        .funct_i(instruction[5:0]),
        .ALUOp_i(ALU_op),
        .ALUCtrl_o(ALU_Ctrl),
        .isShiftLeft_o(isShiftLeft),
        .shamtIsRs_o(shamtIsRs),
        .isShiftInstr_o(isShiftInstr),
        .jr_o(jr)
);


// MEM
MUX_2to1 #(.size(1)) Mux_for_zero_or_notZero_based_on_branchType(
        .data0_i(zero),
        .data1_i(~zero),
        .select_i(BranchType),
        .data_o(data_can_branch)
);

MUX_2to1 #(.size(32)) pc_src_branch_or_not(
        .data0_i(pc_plus_4),
        .data1_i(branch_addr),
        .select_i(Branch & data_can_branch),
        .data_o(pc_addr_after_whether_branch)
);

MUX_2to1 #(.size(32)) Mux_for_Mem_Src_Addr(
        .data0_i(ALU_result),
        .data1_i(shifter_result),
        .select_i(isShiftInstr),
        .data_o(MemSrc_addr)
);

Data_Memory Data_Memory(
	.clk_i(clk_i), 
	.addr_i(MemSrc_addr), 
	.data_i(RTdata), 
	.MemRead_i(MemRead), 
	.MemWrite_i(MemWrite), 
	.data_o(Mem_result)
);

// WB
wire [31:0] pc_src_temp;
assign pc_src_temp = (jr) ? RSdata :
                     (Jump) ? {pc_plus_4[31:28], instruction[25:0], 2'b00} :
                     pc_addr_after_whether_branch;

// MUX_2to1 #(.size(32)) pc_src_jr_or_not(
//         .data0_i(pc_src_temp),
//         .data1_i(RSdata),   // jr
//         .select_i(jr),
//         .data_o(pc_src)
// );


// // Debugging block for observing key signals
// always @(*) begin
//     $display("[DEBUG] pc_plus_4: %h, branch_addr: %h, pc_src: %h", pc_plus_4, branch_addr, pc_src);
//     $display("[DEBUG] instruction: %h, RSdata: %h, RTdata: %h, ALU_result: %h", instruction, RSdata, RTdata, ALU_result);
//     $display("[DEBUG] ALU_Ctrl: %b, isShiftInstr: %b, MemSrc_addr: %h", ALU_Ctrl, isShiftInstr, MemSrc_addr);
// end

MUX_3to1 #(.size(32)) Mux_writeBack_data(
        .data0_i(MemSrc_addr),
        .data1_i(Mem_result),
        .data2_i(pc_plus_4),
        .select_i(MemtoReg),
        .data_o(write_data)
);

endmodule
