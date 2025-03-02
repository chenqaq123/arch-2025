`ifndef __IMM_GEN_SV
`define __IMM_GEN_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
module imm_gen
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    input ImmGenType immGenType,
    output u64 imm_64
);
    always_comb begin
        imm_64 = '0;
        unique case (immGenType)
            NoGen: begin
                imm_64 = '0;
            end
            Gen_1: begin
                imm_64 = {{52{raw_instr[31]}}, raw_instr[31:20]};
            end
            default: begin
                imm_64 = '0;
            end
        endcase
    end
endmodule

`endif