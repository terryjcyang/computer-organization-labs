// File I write/change
`ifndef MUX_2TO1_V
`define MUX_2TO1_V

module MUX_2to1 #(
    parameter size = 1  // Default size: 1
)(
    data0_i,
    data1_i,
    select_i,
    data_o
);

// I/O ports
input   [size-1:0]      data0_i;
input   [size-1:0]      data1_i;
input                   select_i;
output reg [size-1:0]   data_o;

// Internal Signals

// Main function
always @(*) begin
    data_o = (select_i) ? data1_i : data0_i;
end

endmodule

`endif

