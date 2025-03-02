`ifndef __REGFILE_SV
`define __REGFILE_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module regfile

    import common::*;
    import pipes::*;(
    input logic clk, reset,

    input u1 wvalid,
    input creg_addr_t wa,
    input u64 wd,

    input creg_addr_t ra1, ra2,
    output u64 rd1, rd2
);

    u64 [31:0] regs, regs_nxt;

    assign rd1 = regs[ra1];
    assign rd2 = regs[ra2];

    always_ff @(posedge clk) begin
        if (reset) begin
            regs <= '0;
        end else begin
            regs <= regs_nxt;
            regs[0] <= '0;
        end
    end

    for (genvar i = 1; i < 32; i++) begin
        always_comb begin
            if (wvalid && wa == i) begin
                regs_nxt[i] = wd;
            end else begin
                regs_nxt[i] = regs[i];
            end
        end
    end

endmodule



`endif