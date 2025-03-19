`ifndef __ID_EX_REG_SV
`define __ID_EX_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

/*ID/EX流水线寄存器*/
module id_ex_reg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input logic stall,
    input decode_data_t dataD_nxt,
    output decode_data_t dataD
);
    always_ff @(posedge clk) begin
        if(reset) begin
            dataD <= '0;
        end else if(stall) begin
            dataD <= dataD;
        end else begin
            dataD <= dataD_nxt;
        end
    end
endmodule

`endif