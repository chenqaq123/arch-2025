`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/4memory/writedata.sv"
`include "pipeline/4memory/readdata.sv"
`else

`endif


module memory
	import common::*;
	import pipes::*;(
    input execute_data_t dataE,
    output memory_data_t dataM_nxt
);
    // TODO


endmodule

`endif