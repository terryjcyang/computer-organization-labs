// 112550049
`ifndef ALU_CTRL_V
`define ALU_CTRL_V

// both ALU and shifter control
module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o,
        isShiftLeft_o,
        shamtIsRs_o,
        isShiftInstr_o,
        jr_o
        );
          
// I/O ports 
input      [6-1:0] funct_i;     // From the instruction
input      [2-1:0] ALUOp_i;     // From control unit(a decoder)

output     [4-1:0] ALUCtrl_o;  
output     isShiftLeft_o;
output     shamtIsRs_o;           // for sllv, srlv
output     isShiftInstr_o;
output     jr_o;
     
// Internal Signals
reg [3:0]       ALU_Ctrl;
reg             isShiftLeft;
reg             shamtIsRs;
reg             jr;

// Main function
// Ref. to slide p43
always @(*) begin
        jr = 0;
        if(ALUOp_i == 2'b00)            // lw / sw
                ALU_Ctrl = 4'b0010;
        else if(ALUOp_i == 2'b01)       // branch
                ALU_Ctrl = 4'b0110;
        else begin                      // R-format
                shamtIsRs = 0;
                case (funct_i)          // Ref. to spec. p6
                        6'b100010: ALU_Ctrl = 4'b0010; // add
                        6'b100000: ALU_Ctrl = 4'b0110; // sub
                        6'b100101: ALU_Ctrl = 4'b0000; // and
                        6'b100100: ALU_Ctrl = 4'b0001; // or
                        6'b101010: ALU_Ctrl = 4'b1100; // nor
                        6'b100111: ALU_Ctrl = 4'b0111; // slt

                        // fuction field is defined in spec
                        0:  isShiftLeft = 1;  // sll
                        2:  isShiftLeft = 0;  // srl
                        4:  begin 
                                isShiftLeft = 1;  // sllv
                                shamtIsRs = 1; 
                        end
                        6:  begin 
                                isShiftLeft = 0;  // srlv
                                shamtIsRs = 1; 
                        end
                        6'b001000: begin // jr
                                jr = 1;
                                ALU_Ctrl = 4'bxxxx; // No ALU operation for jr
                        end
                        default:;
                endcase
        end

end  

assign ALUCtrl_o = ALU_Ctrl;
assign isShiftLeft_o = isShiftLeft;
assign shamtIsRs_o = shamtIsRs;
assign isShiftInstr_o = (ALUOp_i == 2'b00 && (funct_i == 6'b000000 || funct_i == 6'b000010 || funct_i == 6'b000100 || funct_i == 6'b000110));
assign jr_o = jr;
endmodule

`endif