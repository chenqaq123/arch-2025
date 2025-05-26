`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module decoder
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    output reg_use_type regUseType,
    output control_t ctl
);

    u7 opcode;
    u3 f3;
    logic f7_diff;

    always_comb begin
        ctl = '0;
        regUseType = NO_RS1_RS2;
        opcode = raw_instr[6:0];
        f3 = raw_instr[14:12];
        f7_diff = raw_instr[30];
        unique case (opcode)
            opcode_I: begin
                regUseType = ONLY_RS1;
                ctl.regwrite = 1;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case (f3)
                    F3_addi: begin
                        // ctl.op = ADDI;
                        ctl.alufunc = ALU_ADD;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                    end
                    F3_xori: begin
                        // ctl.op = XORI;
                        ctl.alufunc = ALU_XOR;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                    end
                    F3_ori: begin
                        // ctl.op = ORI;
                        ctl.alufunc = ALU_OR;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                    end
                    F3_andi: begin
                        // ctl.op = ANDI;
                        ctl.alufunc = ALU_AND;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                    end
                    F3_slti: begin
                        ctl.alufunc = ALU_S_LESS;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                    end
                    F3_sltiu: begin
                        ctl.alufunc = ALU_U_LESS;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                    end
                    F3_slli:begin
                        ctl.alufunc = ALU_L_SL;
                        ctl.alusrc = FromShamt;
                        ctl.immGenType = NoGen;
                    end
                    F3_srli_OR_srai: begin
                        unique case (f7_diff)
                            1'b0: begin //srli
                                ctl.alufunc = ALU_L_SR;
                                ctl.alusrc = FromShamt;
                                ctl.immGenType = NoGen;
                            end
                            1'b1: begin //srai
                                ctl.alufunc = ALU_A_SR;
                                ctl.alusrc = FromShamt;
                                ctl.immGenType = NoGen;
                            end
                            default: begin
                                ctl.alufunc = ALU_UNKNOWN;
                                ctl.alusrc = NoSrc;
                                ctl.immGenType = NoGen;
                            end
                        endcase
                    end
                    default: begin
                        // ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                        ctl.alusrc = NoSrc;
                        ctl.immGenType = NoGen;
                    end
                endcase
            end
            opcode_R: begin
                regUseType = BOTH_RS1_RS2;
                ctl.regwrite = 1;
                ctl.alusrc = FromReg;
                ctl.immGenType = NoGen;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case (f3)
                    F3_add_OR_sub: begin
                        unique case (f7_diff)
                            1'b0: begin
                                // ctl.op = ADD;
                                ctl.alufunc = ALU_ADD;
                            end
                            1'b1: begin
                                // ctl.op = SUB;
                                ctl.alufunc = ALU_SUB;
                            end
                            default: begin
                                // ctl.op = UNKNOWN;
                                ctl.alufunc = ALU_UNKNOWN;
                            end
                        endcase
                    end
                    F3_xor: begin
                        // ctl.op = XOR;
                        ctl.alufunc = ALU_XOR;
                    end
                    F3_or: begin
                        // ctl.op = OR;
                        ctl.alufunc = ALU_OR;
                    end
                    F3_and: begin
                        // ctl.op = AND;
                        ctl.alufunc = ALU_AND;
                    end
                    F3_sll: begin 
                        ctl.alufunc = ALU_L_SL;
                    end
                    F3_srl_OR_sra: begin
                        unique case (f7_diff)
                            1'b0: begin //srl
                                ctl.alufunc = ALU_L_SR;
                            end
                            1'b1: begin //sra
                                ctl.alufunc = ALU_A_SR;
                            end
                            default: begin
                                ctl.alufunc = ALU_UNKNOWN;
                            end
                        endcase
                    end
                    F3_slt: begin
                        ctl.alufunc = ALU_S_LESS;
                    end
                    F3_sltu: begin
                        ctl.alufunc = ALU_U_LESS;
                    end
                    default: begin
                        // ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                    end
                endcase
            end
            opcode_I_IW: begin
                regUseType = ONLY_RS1;
                ctl.regwrite = 1;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.MemToReg = 0;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case (f3)
                    F3_addiw: begin
                        // ctl.op = ADDIW;
                        ctl.alufunc = ALU_ADDIW;
                        ctl.alusrc = FromImm;
                        ctl.immGenType = Gen_1;
                        ctl.wbType = WBNoHandle;
                    end
                    F3_slliw: begin 
                        ctl.alufunc = ALU_L_SLIW;
                        ctl.alusrc = FromShamt;
                        ctl.immGenType = NoGen;
                        ctl.wbType = WBNoHandle;
                    end
                    F3_srliw_OR_sraiw: begin
                        unique case (f7_diff)
                            1'b0: begin //srliw
                                ctl.alufunc = ALU_L_SRIW;
                                ctl.alusrc = FromShamt;
                                ctl.immGenType = NoGen;
                                ctl.wbType = WBNoHandle;
                            end
                            1'b1: begin //sraiw
                                ctl.alufunc = ALU_A_SRIW;
                                ctl.alusrc = FromShamt;
                                ctl.immGenType = NoGen;
                                ctl.wbType = WBNoHandle;
                            end
                            default: begin
                                ctl.alufunc = ALU_UNKNOWN;
                                ctl.alusrc = NoSrc;
                                ctl.immGenType = NoGen;
                                ctl.wbType = WBNoHandle;
                            end
                        endcase
                    end
                    default: begin
                        ctl.alufunc = ALU_UNKNOWN;
                        ctl.alusrc = NoSrc;
                        ctl.immGenType = NoGen;
                        ctl.wbType = WBNoHandle;
                    end
                endcase
            end
            opcode_R_W: begin
                regUseType = BOTH_RS1_RS2;
                ctl.regwrite = 1;
                ctl.alusrc = FromReg;
                ctl.immGenType = NoGen;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case (f3)
                    F3_addw_OR_subw: begin
                        unique case (f7_diff)
                            1'b0: begin
                                // ctl.op = ADDW;
                                ctl.alufunc = ALU_ADDW;
                            end
                            1'b1: begin
                                // ctl.op = SUBW;
                                ctl.alufunc = ALU_SUBW;
                            end
                            default: begin
                                // ctl.op = UNKNOWN;
                                ctl.alufunc = ALU_UNKNOWN;
                            end
                        endcase
                    end
                    F3_sllw: begin 
                        ctl.alufunc = ALU_L_SLW;
                    end
                    F3_srlw_OR_sraw: begin
                        unique case (f7_diff)
                            1'b0: begin //srlw
                                ctl.alufunc = ALU_L_SRW;
                            end
                            1'b1: begin //sraw
                                ctl.alufunc = ALU_A_SRW;
                            end
                            default: begin
                                ctl.alufunc = ALU_UNKNOWN;
                            end
                        endcase
                    end
                    default: begin
                        // ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                    end
                endcase
            end
            opcode_I_load: begin
                regUseType = ONLY_RS1;
                ctl.alusrc = FromImm;
                ctl.immGenType = Gen_1;
                ctl.MemRead = 1;
                ctl.MemWrite = 0;
                ctl.alufunc = ALU_ADD;
                ctl.regwrite = 1;
                ctl.MemToReg = 1;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case (f3)
                    F3_lb: begin
                        ctl.MemSize = MSize_8bits;
                        ctl.wbType = WB_7_sext;
                    end
                    F3_lh: begin
                        ctl.MemSize = MSize_16bits;
                        ctl.wbType = WB_15_sext;
                    end
                    F3_lw: begin
                        ctl.MemSize = MSize_32bits;
                        ctl.wbType = WB_31_sext;
                    end
                    F3_ld: begin
                        ctl.MemSize = MSize_64bits;
                        ctl.wbType = WB_63;
                    end
                    F3_lbu: begin
                        ctl.MemSize = MSize_8bits;
                        ctl.wbType = WB_7;
                    end
                    F3_lhu: begin
                        ctl.MemSize = MSize_16bits;
                        ctl.wbType = WB_15;
                    end
                    F3_lwu: begin
                        ctl.MemSize = MSize_32bits;
                        ctl.wbType = WB_31;
                    end
                    default: begin
                        ctl = '0;
                    end
                endcase
            end
            opcode_S: begin
                regUseType = BOTH_RS1_RS2;
                ctl.alusrc = FromImm;
                ctl.immGenType = Gen_4;
                ctl.MemRead = 0;
                ctl.MemWrite = 1;
                ctl.alufunc = ALU_ADD;
                ctl.regwrite = 0;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case (f3)
                    F3_sb: begin
                        ctl.MemSize = MSize_8bits;
                    end
                    F3_sh: begin
                        ctl.MemSize = MSize_16bits;
                    end
                    F3_sw: begin
                        ctl.MemSize = MSize_32bits;
                    end
                    F3_sd: begin
                        ctl.MemSize = MSize_64bits;
                    end
                    default: begin
                        ctl = '0;
                    end
                endcase
            end
            opcode_B: begin
                regUseType = BOTH_RS1_RS2;
                ctl.regwrite = 0;
                ctl.alusrc = FromReg;
                ctl.immGenType = Gen_3;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.alufunc = ALU_B;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
                unique case(f3) 
                    F3_beq: begin
                        ctl.branchType = Branch_eq;
                    end
                    F3_bne: begin 
                        ctl.branchType = Branch_ne;
                    end
                    F3_blt: begin 
                        ctl.branchType = Branch_less_s;
                    end
                    F3_bltu: begin 
                        ctl.branchType = Branch_less_u;
                    end
                    F3_bge: begin 
                        ctl.branchType = Branch_ge_s;
                    end
                    F3_bgeu: begin 
                        ctl.branchType = Branch_ge_u;
                    end
                    default: begin
                        ctl.branchType = NoBranch;
                    end
                endcase
            end
            opcode_U_lui: begin
                regUseType = NO_RS1_RS2;
                ctl.alusrc = FromImm;
                ctl.immGenType = Gen_2;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.alufunc = ALU_LINK;
                ctl.regwrite = 1;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
            end
            opcode_U_auipc: begin
                regUseType = NO_RS1_RS2;
                ctl.regwrite = 1;
                ctl.MemToReg = 0;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.alufunc = ALU_LINK;
                ctl.alusrc = FromPcAddImm;
                ctl.branchType = NoBranch;
                ctl.immGenType = Gen_2;
                ctl.wbType = WBNoHandle;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
            end
            opcode_J_jal: begin
                regUseType = NO_RS1_RS2;
                ctl.regwrite = 1;
                ctl.MemToReg = 0;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.alufunc = ALU_LINK;
                ctl.alusrc = FromPcAdd4;
                ctl.branchType = Branch_jal;
                ctl.immGenType = Gen_5;
                ctl.wbType = WBNoHandle;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
            end
            opcode_J_jalr: begin
                regUseType = ONLY_RS1;
                ctl.regwrite = 1;
                ctl.MemToReg = 0;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.alufunc = ALU_LINK;
                ctl.alusrc = FromPcAdd4;
                ctl.branchType = Branch_jalr;
                ctl.immGenType = Gen_1;
                ctl.wbType = WBNoHandle;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
            end
            opcode_I_CSR: begin
                ctl.alusrc = FromCSR;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.regwrite = 1;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 1;
                ctl.WriteCSR = 1;
                ctl.isCSR = 1;
                ctl.CSR_FROM_zimm = 0;
                unique case (f3)
                    F3_csrrw: begin
                        ctl.immGenType = NoGen;
                        ctl.alufunc = ALU_RS1_ADD_0;
                        regUseType = ONLY_RS1;
                        ctl.CSR_FROM_zimm = 0;
                        ctl.isCSRRC = 0;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                    F3_csrrs: begin
                        ctl.immGenType = NoGen;
                        ctl.alufunc = ALU_OR;
                        regUseType = ONLY_RS1;
                        ctl.CSR_FROM_zimm = 0;
                        ctl.isCSRRC = 0;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                    F3_csrrc: begin
                        ctl.immGenType = NoGen;
                        ctl.alufunc = ALU_CSRRC;
                        regUseType = ONLY_RS1;
                        ctl.CSR_FROM_zimm = 0;
                        ctl.isCSRRC = 1;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                    F3_csrrwi: begin
                        ctl.immGenType = Gen_CSR;
                        ctl.alufunc = ALU_RS1_ADD_0;
                        regUseType = NO_RS1_RS2;
                        ctl.CSR_FROM_zimm = 1;
                        ctl.isCSRRC = 0;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                    F3_csrrsi: begin
                        ctl.immGenType = Gen_CSR;
                        ctl.alufunc = ALU_OR;
                        regUseType = NO_RS1_RS2;
                        ctl.CSR_FROM_zimm = 1;
                        ctl.isCSRRC = 0;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                    F3_csrrci: begin
                        ctl.immGenType = Gen_CSR;
                        ctl.alufunc = ALU_CSRRC;
                        regUseType = NO_RS1_RS2;
                        ctl.CSR_FROM_zimm = 1;
                        ctl.isCSRRC = 1;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                    F3_e: begin
                        unique case (raw_instr[31:25])
                            F7_ecall: begin
                                ctl.immGenType = NoGen;
                                ctl.alufunc = ALU_B;
                                regUseType = NO_RS1_RS2;
                                ctl.CSR_FROM_zimm = 0;
                                ctl.isCSRRC = 0;
                                ctl.isEcall = 1;
                                ctl.isMRET = 0;
                            end
                            F7_mret: begin
                                ctl.immGenType = NoGen;
                                ctl.alufunc = ALU_B;
                                regUseType = NO_RS1_RS2;
                                ctl.CSR_FROM_zimm = 0;
                                ctl.isCSRRC = 0;
                                ctl.isEcall = 0;
                                ctl.isMRET = 1;
                            end
                            F7_fence: begin
                                ctl.immGenType = NoGen;
                                ctl.alufunc = ALU_B;
                                regUseType = NO_RS1_RS2;
                                ctl.CSR_FROM_zimm = 0;
                                ctl.isCSRRC = 0;
                                ctl.isEcall = 0;
                                ctl.isMRET = 0;
                            end
                            default: begin
                                ctl.immGenType = NoGen;
                                ctl.alufunc = ALU_UNKNOWN;
                                regUseType = NO_RS1_RS2;
                                ctl.CSR_FROM_zimm = 0;
                                ctl.isCSRRC = 0;
                                ctl.isEcall = 0;
                                ctl.isMRET = 0;
                            end
                        endcase
                    end
                    default: begin
                        ctl.immGenType = NoGen;
                        ctl.alufunc = ALU_UNKNOWN;
                        regUseType = NO_RS1_RS2;
                        ctl.CSR_FROM_zimm = 0;
                        ctl.isCSRRC = 0;
                        ctl.isEcall = 0;
                        ctl.isMRET = 0;
                    end
                endcase
            end
            default: begin
                ctl.regwrite = 0;
                ctl.alusrc = FromReg;
                ctl.immGenType = NoGen;
                // ctl.op = UNKNOWN;
                ctl.alufunc = ALU_UNKNOWN;
                ctl.MemRead = 0;
                ctl.MemWrite = 0;
                ctl.MemSize = MSize_zero;
                ctl.MemToReg = 0;
                ctl.wbType = WBNoHandle;
                ctl.branchType = NoBranch;
                ctl.ReadCSR = 0;
                ctl.WriteCSR = 0;
                ctl.isCSR = 0;
                ctl.isCSRRC = 0;
                ctl.CSR_FROM_zimm = 0;
                ctl.isEcall = 0;
                ctl.isMRET = 0;
            end
        endcase
    end

    
endmodule


`endif
