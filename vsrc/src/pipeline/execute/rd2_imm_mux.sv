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
    input u64 rd2_from_register, imm_64, pc_add_4, pc_add_imm,
    input u6 shamt,
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
            FromShamt: begin
                rd2 = { {58{'0}}, {shamt[5:0]} };
            end
            FromReg: begin
                rd2 = rd2_from_register;
            end
            FromPcAdd4: begin
                rd2 = pc_add_4;
            end
            FromPcAddImm: begin
                rd2 = pc_add_imm;
            end
            default: begin
                rd2 = '0;
            end
        endcase
    end
endmodule

`endif