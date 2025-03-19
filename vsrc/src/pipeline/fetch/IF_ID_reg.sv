`ifndef __IF_ID_REG_SV
`define __IF_ID_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

// IF/ID流水线寄存器
module if_id_reg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input logic stallpc,
    input logic if_id_write,
    input fetch_data_t dataF_nxt,
    output fetch_data_t dataF
);
    always_ff @(posedge clk) begin
        if(reset) begin
            dataF <= '0;
        end else if(if_id_write) begin
            dataF <= dataF_nxt;
        end else if () begin 
        end else begin
            dataF <= dataF;
        end
    end

endmodule

`endif