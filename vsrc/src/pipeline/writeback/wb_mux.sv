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
    output u64 wd 
);
    assign wd = ALU_out;
endmodule

`endif