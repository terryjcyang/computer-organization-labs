// 112550049
module Sign_Extend(
    data_i,
    data_o
    );
               
// I/O ports
input [16-1:0]          data_i;

output reg [32-1:0]     data_o;

// Internal Signals

// Main function
integer i;
always @(*) begin
    data_o = 32'b0; // Initialize to zero
    data_o[15:0] = data_i[15:0];

    for(i = 31; i >= 16; i = i - 1)
        data_o[i] = data_i[15];
end
          
endmodule
