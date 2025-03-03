`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif


module memory
	import common::*;
	import pipes::*;(
    input execute_data_t dataE,
    output memory_data_t dataM_nxt
);
    assign dataM_nxt.pc = dataE.pc;
    assign dataM_nxt.raw_instr = dataE.raw_instr;

    assign dataM_nxt.ctl = dataE.ctl;
    assign dataM_nxt.dst = dataE.dst;
    assign dataM_nxt.alu_out = dataE.alu_out;

    assign dataM_nxt.valid = dataE.valid;

endmodule

`endif