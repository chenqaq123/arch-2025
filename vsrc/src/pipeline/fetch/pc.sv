`ifndef __PC_SV
`define __PC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pc
    import common::*;
    import pipes::*;(
    input logic reset, clk,
    input logic pc_write,

    input u64 pc_nxt,
    output u64 pc
);
    always_ff @( posedge clk ) begin
        if(reset) begin
            pc <= 64'h8000_0000;
        end else if(pc_write) begin
            pc <= pc_nxt;
        end else begin
            pc <= pc;
        end
    end
endmodule

`endif