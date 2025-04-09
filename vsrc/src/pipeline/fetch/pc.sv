`ifndef __PC_SV
`define __PC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pc
    import common::*;
    import pipes::*;(
    input logic reset, clk,
    input logic pc_write,
    input logic pc_store,

    input u64 pc_nxt,
    output u64 pc
);

    u64 storedPC;
    logic PCStored;
    always_ff @( posedge clk ) begin
        if(reset) begin
            PCStored <= '0;
            pc <= 64'h8000_0000;
        end else if(PCStored & pc_write) begin
            pc <= storedPC;
            PCStored <= '0;
        end else if(pc_write) begin
            pc <= pc_nxt;
            PCStored <= PCStored;
        end else begin
            pc <= pc;
            PCStored <= PCStored;
        end

        if (pc_store) begin
            storedPC <= pc_nxt;
            PCStored <= '1;
        end
    end
endmodule

`endif