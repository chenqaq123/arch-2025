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
    output control_t ctl
);

    u7 opcode;
    u3 f3;
    logic f7_diff;

    always_comb begin
        ctl = '0;
        opcode = raw_instr[6:0];
        f3 = raw_instr[14:12];
        f7_diff = raw_instr[30];
        unique case (opcode)
            opcode_I: begin
                ctl.regwrite = 1;
                ctl.alusrc = FromImm;
                ctl.immGenType = Gen;
                unique case (f3)
                    F3_addi: begin
                        ctl.op = ADDI;
                        ctl.alufunc = ALU_ADD;
                    end
                    F3_xori: begin
                        ctl.op = XORI;
                        ctl.alufunc = ALU_XOR;
                    end
                    F3_ori: begin
                        ctl.op = ORI;
                        ctl.alufunc = ALU_OR;
                    end
                    F3_andi: begin
                        ctl.op = ANDI;
                        ctl.alufunc = ALU_AND;
                    end
                    default: begin
                        ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                    end
                endcase
            end
            opcode_R: begin
                ctl.regwrite = 1;
                ctl.alusrc = FromReg;
                ctl.immGenType = NoGen;
                unique case (f3)
                    F3_add_OR_sub: begin
                        unique case (f7_diff)
                            1'b0: begin
                                ctl.op = ADD;
                                ctl.alufunc = ALU_ADD;
                            end
                            1'b1: begin
                                ctl.op = SUB;
                                ctl.alufunc = ALU_SUB;
                            end
                            default: begin
                                ctl.op = UNKNOWN;
                                ctl.alufunc = ALU_UNKNOWN;
                            end
                        endcase
                    end
                    F3_xor: begin
                        ctl.op = XOR;
                        ctl.alufunc = ALU_XOR;
                    end
                    F3_or: begin
                        ctl.op = OR;
                        ctl.alufunc = ALU_OR;
                    end
                    F3_and: begin
                        ctl.op = AND;
                        ctl.alufunc = ALU_AND;
                    end
                    default: begin
                        ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                    end
                endcase
            end
            opcode_I_IW: begin
                ctl.regwrite = 1;
                ctl.alusrc = FromImm;
                ctl.immGenType = Gen;
                unique case (f3)
                    F3_addiw: begin
                        ctl.op = ADDIW;
                        ctl.alufunc = ALU_ADDIW;
                    end
                    default: begin
                        ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                    end
                endcase
            end
            opcode_R_W: begin
                ctl.regwrite = 1;
                ctl.alusrc = FromReg;
                ctl.immGenType = NoGen;
                unique case (f3)
                    F3_addw_OR_subw: begin
                        unique case (f7_diff)
                            1'b0: begin
                                ctl.op = ADDW;
                                ctl.alufunc = ALU_ADDW;
                            end
                            1'b1: begin
                                ctl.op = SUBW;
                                ctl.alufunc = ALU_SUBW;
                            end
                            default: begin
                                ctl.op = UNKNOWN;
                                ctl.alufunc = ALU_UNKNOWN;
                            end
                        endcase
                    end
                    default: begin
                        ctl.op = UNKNOWN;
                        ctl.alufunc = ALU_UNKNOWN;
                    end
                endcase
            end
            default: begin
                ctl.regwrite = 0;
                ctl.alusrc = FromReg;
                ctl.immGenType = NoGen;
                ctl.op = UNKNOWN;
                ctl.alufunc = ALU_UNKNOWN;
            end

        endcase
    end

    
endmodule


`endif
