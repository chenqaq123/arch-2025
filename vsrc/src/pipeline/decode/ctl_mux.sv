`ifndef __CTL_MUX_SV
`define __CTL_MUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module ctl_mux
    import common::*;
    import pipes::*;(
    input control_t ctl_nxt,
    input logic stall_control_sign,
    output control_t ctl
);
    assign ctl = stall_control_sign ? '0 : ctl_nxt;
endmodule

`endif