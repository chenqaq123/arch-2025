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
    logic[31:0] imm_32;
    logic[12:0] imm_13;
    logic[11:0] imm_12;
    logic[20:0] imm_21;
    always_comb begin
        // 为所有中间变量添加默认值
        imm_64 = '0;
        imm_32 = '0;
        imm_13 = '0;
        imm_12 = '0;
        imm_21 = '0;

        unique case (immGenType)
            NoGen: begin
                imm_64 = '0;
            end
            Gen_1: begin
                imm_64 = {{52{raw_instr[31]}}, raw_instr[31:20]};
            end
            // lui
            Gen_2: begin
                imm_32 = {{raw_instr[31:12]}, {12{'0}}};
                imm_64 = {{32{imm_32[31]}}, imm_32[31:0]};
            end
            Gen_3: begin
                // B类型的条件跳转
                imm_13 = {{raw_instr[31]},{raw_instr[7]},{raw_instr[30:25]},{raw_instr[11:8]},{1'b0}};
                imm_64 = {{51{imm_13[12]}}, imm_13[12:0]};
            end
            // sd
            Gen_4: begin
                imm_12 = {{raw_instr[31:25]}, {raw_instr[11:7]}};
                imm_64 = {{52{imm_12[11]}}, imm_12[11:0]};
            end
            Gen_5: begin
                // jal
                imm_21 = {{raw_instr[31]}, {raw_instr[19:12]}, {raw_instr[20]}, {raw_instr[30:21]}, {1'b0}};
                imm_64 = {{43{imm_21[20]}}, {imm_21[20:0]}};
            end
            Gen_CSR: begin
                imm_64 = {59'b0, raw_instr[19:15]};
            end
            default: begin
                imm_64 = '0;
            end
        endcase
    end
endmodule

`endif