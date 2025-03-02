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
    input fetch_data_t dataF_nxt,
    output fetch_data_t dataF
);
    fetch_data_t dataFReg;

    always_ff @(posedge clk) begin
        if(reset | flush) begin
            dataFReg <= '0;
        end else begin
            dataFReg <= dataF_nxt;
        end
    end

    assign dataF = dataFReg;

endmodule

`endif