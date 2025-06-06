`ifndef __EX_MEM_REG_SV
`define __EX_MEM_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

// EX/MEM流水线寄存器
module ex_mem_reg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input logic flush,
    input logic csr_flush,
    input logic stall,
    input execute_data_t dataE_nxt,
    output execute_data_t dataE
);
    always_ff @(posedge clk) begin
        if(reset | flush) begin
            dataE <= '0;
        end else if(stall) begin
            dataE <= dataE;
        end else if(csr_flush) begin
            dataE <= '0;
        end else begin
            dataE <= dataE_nxt;
        end
    end
endmodule

`endif