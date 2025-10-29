///
wire pc_src;
assign pc_src = (branch_EX[0] & alu_zero_EX) | (branch_EX[1] & ~alu_zero_EX);
always @(posedge clk_i)begin
    //$display("write_reg: %d", mux_write_reg_MEM);
    $display("pc_src = %b, branch_EX = %b, alu_zero_EX = %b", pc_src, branch_EX, alu_zero_EX);
    //$display("D1: %h, D2: %h", ReadData1_ID, mux_alu_src);
    $display("pc_o = %d", pc_o);
    $display("----ReadData1 = %h, ReadData2 = %h at time %t", ReadData1, ReadData2, $time);
end