`ifndef __WB_MUX_SV
`define __WB_MUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module wb_mux
    import common::*;
    import pipes::*;(
    input u64 ALU_out,
    input u64 MemReadData,
    input logic MemToReg,
    input u1 isCSR,
    input u64 csr_rdata,
    output u64 wd 
);
    assign wd = isCSR ? csr_rdata : (MemToReg ? MemReadData : ALU_out);
endmodule

`endif