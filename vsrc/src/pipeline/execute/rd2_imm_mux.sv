`ifndef __RD2_IMM_MUX_SV
`define __RD2_IMM_MUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module rd2_imm_mux
    import common::*;
    import pipes::*;(
    input u64 rd2_from_register, imm_64,
    input ALUSRCType ALUSRC,
    output u64 rd2
);

    always_comb begin
        unique case (ALUSRC)
            NoSrc: begin
                rd2 = '0;
            end
            FromImm: begin
                rd2 = imm_64;
            end
            FromReg: begin
                rd2 = rd2_from_register;
            end
            default: begin
                rd2 = '0;
            end
        endcase
    end
endmodule

`endif