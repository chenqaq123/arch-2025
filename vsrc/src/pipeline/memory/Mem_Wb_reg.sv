`ifndef __MEM_WB_REG_SV
`define __MEM_WB_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

// MEM/WB流水线寄存器
module mem_wb_reg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input memory_data_t dataM_nxt,
    output memory_data_t dataM
);
    always_ff @(posedge clk) begin
        if(reset) begin
            dataM <= '0; //valid也会为0
        end else begin
            dataM <= dataM_nxt;
        end
    end
endmodule

`endif