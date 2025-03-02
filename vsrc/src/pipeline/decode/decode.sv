`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input fetch_data_t dataF,
    input word_t rd1, rd2,
    
    output decode_data_t dataD_nxt,
    output creg_addr_t ra1, ra2
);

    control_t ctl;

    decoder decoder (
        .raw_instr(dataF.raw_instr),
        .ctl(ctl)
    );

    assign dataD_nxt.ctl = ctl;
    assign dataD_nxt.dst = dataF.raw_instr[11:7];

    assign dataD_nxt.srca = rd1;
    assign dataD_nxt.srcb = rd2;

    
    
endmodule


`endif
