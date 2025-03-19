`ifndef __FETCH_SV
`define __FETHC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module fetch 
    import common::*;
    import pipes::*;(
    input u64 pc,
    input u32 raw_instr,
    input logic valid,
    output fetch_data_t dataF_nxt
);  

    always_comb begin
        dataF_nxt.valid = valid;
        dataF_nxt.raw_instr = raw_instr;
        if(valid) begin
            dataF_nxt.pc = pc;
        end else begin
            dataF_nxt.pc = dataF_nxt.pc;
        end
    end

endmodule



`endif

