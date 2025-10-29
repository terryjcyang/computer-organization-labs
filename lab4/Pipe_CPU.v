// 112550049
`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"

`timescale 1ns / 1ps

module Pipe_CPU(
    clk_i,
    rst_i
    );

input clk_i;
input rst_i;

// Internal signal
wire [32-1:0] pc_i, pc_o, pc_add4, pc_addSA;
wire [32-1:0] instr;

wire [1:0] reg_dst;
wire [5-1:0] mux_write_reg;
wire reg_write;
wire [32-1:0] ReadData1, ReadData2;

wire [2-1:0] alu_op;
wire [2-1:0] branch;
wire alu_src, jump, mem_read, mem_write;

wire [2-1:0] mem_to_reg;
wire [4-1:0] alu_ctrl;

wire [32-1:0] sign_ext, shift_addr;

wire [32-1:0] mux_alu_src, mux_datamem, mux_branch;

wire [32-1:0] alu_result;
wire  alu_zero, cout, overflow;

wire  shift_content; 
wire [32-1:0] shiter_result;
wire [32-1:0] data_mem, write_data;

    // Pipline Register signal
wire [32-1:0] pc_add4_IF;
wire [32-1:0] instr_IF;

wire [2-1:0] alu_op_ID, reg_dst_ID, branch_ID, mem_to_reg_ID;
wire  alu_src_ID, reg_write_ID, mem_read_ID, mem_write_ID;
wire [32-1:0] pc_add4_ID;
wire [32-1:0] ReadData1_ID, ReadData2_ID, sign_ext_ID;
wire [20:11]  instr_ID;

wire [2-1:0] branch_EX, mem_to_reg_EX;
wire  reg_write_EX, mem_read_EX, mem_write_EX;
wire [32-1:0] pc_addSA_EX;
wire alu_zero_EX;
wire [32-1:0] alu_result_EX;
wire [32-1:0] ReadData2_EX;
wire [5-1:0] mux_write_reg_EX;

wire [2-1:0] mem_to_reg_MEM;
wire reg_write_MEM;
wire [32-1:0] data_mem_MEM;
wire [32-1:0] alu_result_MEM;
wire [5-1:0] mux_write_reg_MEM;


// Components

// Components in IF stage
MUX_2to1 #(.size(32)) Mux_Branch(
        .data0_i(pc_add4),
        .data1_i(pc_addSA_EX),
        .select_i((branch_EX[0] & alu_zero_EX) | (branch_EX[1] & ~alu_zero_EX)), // beq or bne
        .data_o(pc_i)   // directly go to pc since no j or jr here
);

ProgramCounter PC(
        .clk_i(clk_i),      
        .rst_i(rst_i),     
        .pc_in_i(pc_i),   
        .pc_out_o(pc_o) 
);

Adder Adder_PC_Add4(
        .src1_i(pc_o),     
        .src2_i(32'd4),
        .sum_o(pc_add4)    
);

Instruction_Memory IM(
        .addr_i(pc_o),  
        .instr_o(instr)    
);

// IF/ID Reg
Pipe_Reg #(.size(32 + 32)) IF_ID_Pipe_Reg(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({
            pc_add4, 
            instr}),
        .data_o({
            pc_add4_IF, 
            instr_IF})     // _IF: pipline data from IF stage to next stage
);

// Components in ID stage
Decoder Decoder(
        .instr_op_i(instr_IF[31:26]),  
        .ALU_op_o(alu_op),   
        .ALUSrc_o(alu_src),
        .RegWrite_o(reg_write),   
        .RegDst_o(reg_dst),
        .Branch_o(branch),
        .Jump_o(jump), 
        .MemRead_o(mem_read), 
        .MemWrite_o(mem_write), 
        .MemtoReg_o(mem_to_reg)
);

Reg_File RF(
        .clk_i(clk_i),      
        .rst_i(rst_i) ,     
        .RSaddr_i(instr_IF[25:21]),                // Read Register1
        .RTaddr_i(instr_IF[20:16]),                // Read Register2
        .RDaddr_i(mux_write_reg_MEM),               // Write Register 
        .RDdata_i(write_data),                  // Write Data (from mux in WB directly)
        .RegWrite_i(reg_write_MEM),             // RegWrite
        .RSdata_o(ReadData1),  
        .RTdata_o(ReadData2) 
);
	
Sign_Extend SE(
        .data_i(instr_IF[15:0]),
        .data_o(sign_ext)
);

// ID/EX Reg
Pipe_Reg #(.size(12 + 32 + 64 + 32 + 10)) ID_EX_Pipe_Reg(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({
            alu_op, alu_src, reg_write, reg_dst, branch, mem_read, mem_write, mem_to_reg, 
            pc_add4_IF, 
            ReadData1, ReadData2, 
            sign_ext,
            instr_IF[20:16], instr_IF[15:11]}),
        .data_o({
            alu_op_ID, alu_src_ID, reg_write_ID, reg_dst_ID, branch_ID, mem_read_ID, mem_write_ID, mem_to_reg_ID, 
            pc_add4_ID, 
            ReadData1_ID, ReadData2_ID, 
            sign_ext_ID,
            instr_ID[20:16], instr_ID[15:11]})
);


// Components in EX stage
Shift_Left_Two_32 Shift_address(
    	.data_i(sign_ext_ID),
    	.data_o(shift_addr)
);

Adder Adder_PC_AddSA(       // the adder for branch address
        .src1_i(pc_add4_ID),     
	.src2_i(shift_addr),
	.sum_o(pc_addSA)    
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(ReadData2_ID),
        .data1_i(sign_ext_ID),
        .select_i(alu_src_ID),
        .data_o(mux_alu_src)
);
		
ALU ALU(
	.src1_i(ReadData1_ID),
	.src2_i(mux_alu_src),
	.ctrl_i(alu_ctrl),
	.result_o(alu_result),
	.zero_o(alu_zero),
        .cout(cout),
        .overflow(overflow)
);

ALU_Ctrl AC(
        .funct_i(sign_ext_ID[5:0]),   // R-Type
        .ALUOp_i(alu_op_ID),   
        .ALUCtrl_o(alu_ctrl),
        .shift_content(shift_content)
);

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_ID[20:16]), // rt
        .data1_i(instr_ID[15:11]), // rd
        .select_i(reg_dst_ID[0]),
        .data_o(mux_write_reg)
);

// EX/MEM Reg
Pipe_Reg #(.size(7 + 32 + 33 + 32 + 5)) EX_MEM_Pipe_Reg(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({
            reg_write_ID, branch_ID, mem_read_ID, mem_write_ID, mem_to_reg_ID, 
            pc_addSA, 
            alu_zero, alu_result, 
            ReadData2_ID,
            mux_write_reg
            }),
        .data_o({
            reg_write_EX, branch_EX, mem_read_EX, mem_write_EX, mem_to_reg_EX, 
            pc_addSA_EX, 
            alu_zero_EX, alu_result_EX, 
            ReadData2_EX,
            mux_write_reg_EX
        })
);


// Components in MEM stage
Data_Memory DM(
	.clk_i(clk_i), 
	.addr_i(alu_result_EX), 
	.data_i(ReadData2_EX), 
	.MemRead_i(mem_read_EX), 
	.MemWrite_i(mem_write_EX), 
	.data_o(data_mem)
);	

// MEM/WB Reg
Pipe_Reg #(.size(3 + 32 + 32 + 5)) MEM_WB_Pipe_Reg(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({
            reg_write_EX, mem_to_reg_EX, 
            data_mem,
            alu_result_EX,
            mux_write_reg_EX
            }),
        .data_o({
            reg_write_MEM, mem_to_reg_MEM, 
            data_mem_MEM,
            alu_result_MEM,
            mux_write_reg_MEM
        })
);

// Components in WB stage
MUX_2to1 #(.size(32)) Mux_MemtoReg(
        .data0_i(alu_result_MEM),
        .data1_i(data_mem_MEM),
        .select_i(mem_to_reg_MEM[0]),
        .data_o(write_data)
);


endmodule
