`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/pipeline/decode/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input fetch_data_t dataF,
    input u64 rd1, rd2,
    input control_t ctl,
    input u64 imm_64,
    
    output decode_data_t dataD_nxt
);

    assign dataD_nxt.pc = dataF.pc;
    assign dataD_nxt.raw_instr = dataF.raw_instr;
    
    assign dataD_nxt.ctl = ctl;
    assign dataD_nxt.dst = dataF.raw_instr[11:7];

    assign dataD_nxt.srca = rd1;
    assign dataD_nxt.srcb = rd2;
    assign dataD_nxt.imm_64 = imm_64;

    assign dataD_nxt.valid = dataF.valid;
endmodule


`endif
