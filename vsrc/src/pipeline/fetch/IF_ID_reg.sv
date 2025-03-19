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
    input logic stallM,
    input logic if_id_write,
    input fetch_data_t dataF_nxt,
    output fetch_data_t dataF
);
    always_ff @(posedge clk) begin

        if(reset) begin
            dataF <= '0;
        end else if (stallM) begin 
            dataF <= dataF;
        end else begin
            dataF <= dataF_nxt;
        end

    end

endmodule

`endif