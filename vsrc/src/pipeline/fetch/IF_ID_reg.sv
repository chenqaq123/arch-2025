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
    input logic branch_ctl_flush,
    input logic stallpc,
    input logic stallM,
    input logic if_id_write,
    input fetch_data_t dataF_nxt,
    output fetch_data_t dataF
);
    fetch_data_t dataFReg;
    logic branch_ctl_flush_store; 
    always_ff @(posedge clk) begin
        if(reset) begin
            dataFReg <= '0;
            branch_ctl_flush_store <= '0;
        end else if (stallM) begin 
            dataFReg <= dataFReg;
        end else if (~if_id_write) begin 
            dataFReg <= dataFReg;
        end else if (branch_ctl_flush) begin 
            dataFReg <= '0;
        end else if (stallpc) begin 
            dataFReg <= '0;
        end else if (branch_ctl_flush_store & ~stallpc) begin
            dataFReg <= '0;
            branch_ctl_flush_store <= '0;
        end else begin
            dataFReg <= dataF_nxt;
        end
        if (branch_ctl_flush) begin
            branch_ctl_flush_store <= branch_ctl_flush;
        end
    end

    assign dataF = dataFReg;

endmodule

`endif