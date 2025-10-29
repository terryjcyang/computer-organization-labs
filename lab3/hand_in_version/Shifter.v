// 112550049
module Shifter (
    data_i,
    shamt,
    isShiftLeft_i,
    data_o
);

// I/O ports
input [32-1:0]      data_i;
input [4:0]         shamt;
input               isShiftLeft_i;
output [32-1:0]     data_o;

// Internal Signals


// Main Function
assign data_o = (isShiftLeft_i) ? (data_i << shamt) : (data_i >> shamt);
    
endmodule