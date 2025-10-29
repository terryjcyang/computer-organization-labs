// 112550049
module Forwarding_Unit(
    regwrite_mem,
    regwrite_wb,
    idex_regs,  // ID/EX reg Rs
    idex_regt,
    exmem_regd,
    memwb_regd,
    forwarda,
    forwardb
);

// I/O ports
input               regwrite_mem, regwrite_wb;
input [5-1:0]       idex_regs, idex_regt, exmem_regd, memwb_regd;
output reg [2-1:0]  forwarda, forwardb;

// Internal signal
reg                 mem_regwrite, wb_regwrite; // if will write reg

always @(*) begin
    mem_regwrite = regwrite_mem && (exmem_regd != 0);
    wb_regwrite = regwrite_wb && (memwb_regd != 0);

    // for mux a
    if(mem_regwrite && (idex_regs == exmem_regd)) begin
        forwarda = 2'b01;
    end
    else if(wb_regwrite && (idex_regs == memwb_regd)) begin
        forwarda = 2'b10;
    end
    else begin
        forwarda = 2'b00;
    end

    // for mux b
    if(mem_regwrite && (idex_regt == exmem_regd)) begin
        forwardb = 2'b01;
    end
    else if(wb_regwrite && (idex_regt == memwb_regd)) begin
        forwardb = 2'b10;
    end
    else begin
        forwardb = 2'b00;
    end
end

endmodule