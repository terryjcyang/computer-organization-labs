// File I write/change
module Hazard_Detection(
    memread,
    instr_i,
    idex_regt,
    branch,
    pcwrite,
    ifid_write,
    ifid_flush,
    idex_flush,
    exmem_flush
);

// I/O ports
input               memread;    // ID/EX MemRead : lw happen if 1
input [32-1:0]      instr_i;    // compare Rs, Rt with Rt of lw(prev instr)
input [5-1:0]       idex_regt;  // may be Rt of lw -> load-use
input               branch;     // in MEM stage
output              pcwrite, ifid_write, ifid_flush, idex_flush, exmem_flush;

// Internal signal
wire [5-1:0]        regs, regt;
wire [6-1:0]        op_field;
wire                is_addi, is_lw, read_regt, regt_use_prev_regt;
wire                loadUse;
reg                 pcwrite, ifid_write, ifid_flush, idex_flush, exmem_flush;


assign regs = instr_i[25:21];
assign regt = instr_i[20:16];
assign op_field = instr_i[31:26];

assign is_addi = (op_field == 6'b001000);
assign is_lw = (op_field == 6'b101011);
assign read_regt = ~(is_addi | is_lw);      // here, only these two
assign regt_use_prev_regt = (regt == idex_regt) & read_regt;
assign loadUse = memread & ((regs == idex_regt) | regt_use_prev_regt);

always @(*) begin
    if(branch) begin
        pcwrite = 1;
        ifid_write = 1;
        ifid_flush = 1;
        idex_flush = 1;
        exmem_flush = 1;
    end
    else if(loadUse) begin
        pcwrite = 0;
        ifid_write = 0;
        ifid_flush = 0;
        idex_flush = 1;
        exmem_flush = 0;
    end
    else begin
        pcwrite = 1;
        ifid_write = 1;
        ifid_flush = 0;
        idex_flush = 0;
        exmem_flush = 0;
    end

end

endmodule