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
    input u64 ope2,
    output execute_data_t dataE_nxt
);
    assign dataE_nxt.pc = dataD.pc;
    assign dataE_nxt.raw_instr = dataD.raw_instr;

    assign dataE_nxt.alu_out = alu_out;
    assign dataE_nxt.ctl = dataD.ctl;    
    assign dataE_nxt.dst = dataD.dst;

    assign dataE_nxt.valid = dataD.valid;

    assign dataE_nxt.MemWriteData = dataD.srcb;

    assign dataE_nxt.rd1 = dataD.srca;
    assign dataE_nxt.rd2 = ope2;
    assign dataE_nxt.imm_64 = dataD.imm_64;
    assign dataE_nxt.csr = dataD.csr;
    assign dataE_nxt.csr_rdata = dataD.csr_rdata;
endmodule

`endif