`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pc_mux 
    import common::*;
    import pipes::*;(

    input u64 pcplus4,
    output u64 pc_nxt
    
);

    assign pc_nxt = pcplus4;


endmodule


`endif

