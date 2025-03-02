`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module execute
    import common::*;
    import pipes::*;(
    input decode_data_t dataD,
    input u64 alu_out,
    output execute_data_t dataE_nxt
);
    assign dataE_nxt.pc = dataD.pc;
    assign dataE_nxt.raw_instr = dataD.raw_instr;

    assign dataE_nxt.alu_out = alu_out;
    assign dataE_nxt.ctl = dataD.ctl;    
    assign dataE_nxt.dst = dataD.dst;

endmodule

`endif